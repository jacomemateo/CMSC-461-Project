# UMBC Parking Management System (CMSC 461 Final)

Authors: Mateo Jacome, Jason Chen

## Read me grader
Follow these steps in order to stand up the database and seed it with data.

1. **Initalize**
Ensure Docker is running, then execute:
```
task create_db
```

2. **Seed the Database**

    You have two options for data:
   * Small Scale (Test Data): `task seed` (seeds ~10 rows per table).

   * High Volume (Production Scale): `task better_seed` (seeds 100,000+ rows using Go).


3. **Apply Optimizations** Run the indexing script to ensure query performance:

    ```
    task indexes
    ```


4. **Run Smoke Tests**
`Verify the system is operational:
```
task smoke_test
```

## Project Structure

`db/tables/`: Core schema, types, triggers, and stored procedures.

`db/indices/`: Performance optimization scripts.

`db/queries/`: SQL for reporting, business logic, and concurrency demos.

`seeder/`: High-performance Go-based data generator.

`report/`: Final design document and walkthrough.

## Concurrency Control Demo

To view the logic for preventing double-bookings and managing overlapping reservations, refer to:
db/queries/transactions.sql

You can run the demo by opening two separate task connect sessions and following the comments in the SQL file.

## Connection Details

* **Database**: parking (Port 6767)
* **Credentials**: postgres / secret
* **PGAdmin Dashboard**: http://localhost:5050 (admin@example.com / admin)