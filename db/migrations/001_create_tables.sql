CREATE TABLE smoke_test(
    id SERIAL PRIMARY KEY,
    message VARCHAR(255)
);

INSERT INTO smoke_test (message) 
VALUES ('Hello, World!');

SELECT * FROM smoke_test;   