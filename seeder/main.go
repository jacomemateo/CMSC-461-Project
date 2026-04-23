package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"time"

	"github.com/go-faker/faker/v4"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

const (
	totalUsers = 1_000_000
	batchSize  = 10_000
)

var parkingTypes = []string{"STUDENT", "STAFF", "GUEST"}

func main() {
	ctx := context.Background()
	const connStr = "postgres://postgres:secret@localhost:6767/parking"

	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		log.Fatal("Connection failed: ", err)
	}
	defer conn.Close(ctx)

	rand.Seed(time.Now().UnixNano())

	fmt.Println("Initialising session: Disabling triggers and constraints")
	conn.Exec(ctx, "SET session_replication_role = 'replica';")

	fmt.Println("Executing database truncation")
	_, err = conn.Exec(ctx, `TRUNCATE TABLE tickets, payments, permits, sensor_events, reservation, parking_spot, car_info, user_info, lot_info, violations RESTART IDENTITY CASCADE`)
	if err != nil {
		log.Fatal("Truncation failed: ", err)
	}

	fmt.Println("Seeding reference data: Lots and Violations")
	lotIDs := seedLots(ctx, conn)
	seedViolations(ctx, conn)

	fmt.Println("Seeding infrastructure: Parking Spots")
	spotIDs := seedSpots(ctx, conn, lotIDs)

	for i := 0; i < totalUsers; i += batchSize {
		fmt.Printf("Processing batch: %d to %d\n", i, i+batchSize)

		users, cars, permits, payments, reservations, events := generateData(batchSize, i, spotIDs)

		copyData(ctx, conn, "user_info", []string{"id", "first_name", "last_name", "phone", "email", "parking_type"}, users)
		copyData(ctx, conn, "car_info", []string{"id", "owner_id", "plate", "model", "color"}, cars)
		copyData(ctx, conn, "permits", []string{"id", "user_id", "permit_type", "issued_date", "expiration_date"}, permits)
		copyData(ctx, conn, "payments", []string{"id", "user_id", "amount_cents", "date"}, payments)
		copyData(ctx, conn, "reservation", []string{"id", "user_id", "car_id", "parking_spot_id", "start_time", "end_time"}, reservations)
		copyData(ctx, conn, "sensor_events", []string{"id", "parking_spot_id", "event_type", "event_time"}, events)
	}

	fmt.Println("Finalising session: Enabling triggers")
	conn.Exec(ctx, "SET session_replication_role = 'origin';")

	fmt.Println("Synchronising spot occupancy states")
	conn.Exec(ctx, `
		UPDATE parking_spot 
		SET is_occupied = TRUE 
		WHERE id IN (SELECT DISTINCT parking_spot_id FROM sensor_events WHERE event_type = 'ARRIVAL');
	`)

	fmt.Println("Optimising database: Creating functional indexes")
	conn.Exec(ctx, "CREATE INDEX IF NOT EXISTS idx_res_spot_car ON reservation(parking_spot_id, car_id);")
	conn.Exec(ctx, "CREATE INDEX IF NOT EXISTS idx_permits_lookup ON permits(user_id, expiration_date);")

	fmt.Println("Executing automated ticketing procedure")
	startTime := time.Now()
	_, err = conn.Exec(ctx, "CALL pr_generate_tickets()")
	if err != nil {
		log.Printf("Procedure execution error: %v", err)
	}
	fmt.Printf("Database population complete. Execution time: %v\n", time.Since(startTime))
}

func generateData(n, start int, spotIDs []uuid.UUID) (u, c, p, pay, res, ev [][]any) {
	for i := 0; i < n; i++ {
		idx := start + i
		uID := uuid.New()
		cID := uuid.New()
		spotID := spotIDs[rand.Intn(len(spotIDs))]
		pType := parkingTypes[rand.Intn(len(parkingTypes))]

		u = append(u, []any{uID, faker.FirstName(), faker.LastName(), fmt.Sprintf("555-%07d", idx), fmt.Sprintf("u%d@university.edu", idx), pType})
		c = append(c, []any{cID, uID, fmt.Sprintf("PLATE-%d", idx), "Vehicle Model", "Standard Color"})

		if rand.Float32() < 0.8 {
			p = append(p, []any{uuid.New(), uID, pType, time.Now(), time.Now().AddDate(1, 0, 0)})
			pay = append(pay, []any{uuid.New(), uID, 5000, time.Now()})
		}

		if rand.Float32() < 0.3 {
			res = append(res, []any{uuid.New(), uID, cID, spotID, time.Now().Add(-1 * time.Hour), time.Now().Add(1 * time.Hour)})
			ev = append(ev, []any{uuid.New(), spotID, "ARRIVAL", time.Now().Add(-30 * time.Minute)})
		}
	}
	return
}

func copyData(ctx context.Context, conn *pgx.Conn, table string, cols []string, rows [][]any) {
	_, err := conn.CopyFrom(ctx, pgx.Identifier{table}, cols, pgx.CopyFromRows(rows))
	if err != nil {
		log.Fatalf("Bulk insert failed for table %s: %v", table, err)
	}
}

func seedLots(ctx context.Context, conn *pgx.Conn) []uuid.UUID {
	lots := []struct {
		name string
		t    string
	}{
		{"Lot A", "STUDENT"}, {"Lot B", "STAFF"}, {"Lot C", "GUEST"},
		{"Lot D", "STUDENT"}, {"Lot E", "STAFF"}, {"Lot F", "GUEST"},
		{"Lot G", "STUDENT"}, {"Lot H", "STAFF"}, {"Lot I", "GUEST"},
		{"Lot J", "STUDENT"},
	}
	var ids []uuid.UUID
	for _, l := range lots {
		id := uuid.New()
		conn.Exec(ctx, "INSERT INTO lot_info (id, name, lot_type) VALUES ($1, $2, $3)", id, l.name, l.t)
		ids = append(ids, id)
	}
	return ids
}

func seedViolations(ctx context.Context, conn *pgx.Conn) {
	violations := []struct {
		code string
		desc string
		amt  int
	}{
		{"NO_PERMIT", "Parking without a valid permit", 5000},
		{"EXPIRED_METER", "Meter expired", 2500},
		{"INVALID_ZONE", "Parked in wrong zone", 3000},
		{"OVER_TIME", "Exceeded allowed parking time", 2000},
		{"BLOCKING", "Blocking another vehicle or lane", 4000},
		{"FIRE_HYDRANT", "Parked within 15ft of hydrant", 10000},
		{"HANDICAP_ONLY", "Unauthorized parking in accessible spot", 25000},
		{"SIDEWALK_BLOCK", "Vehicle blocking pedestrian walkway", 4500},
		{"WRONG_WAY", "Parked against the flow of traffic", 3500},
		{"ABANDONED", "Vehicle left for over 72 hours", 15000},
	}
	for _, v := range violations {
		conn.Exec(ctx, "INSERT INTO violations (code, description, amount_cents) VALUES ($1, $2, $3)", v.code, v.desc, v.amt)
	}
}

func seedSpots(ctx context.Context, conn *pgx.Conn, lotIDs []uuid.UUID) []uuid.UUID {
	var ids []uuid.UUID
	for _, lID := range lotIDs {
		for i := 1; i <= 100; i++ {
			id := uuid.New()
			conn.Exec(ctx, "INSERT INTO parking_spot (id, lot_id, space) VALUES ($1, $2, $3)", id, lID, i)
			ids = append(ids, id)
		}
	}
	return ids
}