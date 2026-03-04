.PHONY: create_db connect_db nuke_db shutdown_db smoke_test


create_db:
	docker compose up -d

connect_db:
	docker exec -it parking-db psql -U postgres -d parking

shutdown_db:
	docker compose down

nuke_db:
	docker compose down -v

logs_db:
	docker logs parking-db

smoke_test:
	docker exec -i parking-db psql -U postgres -d parking < db/test/smoke_test.sql
