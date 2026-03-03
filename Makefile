.PHONY: create_db connect_db nuke_db shutdown_db 


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

