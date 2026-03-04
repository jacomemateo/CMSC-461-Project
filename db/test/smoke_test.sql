-- code: language=postgres

CREATE TABLE product_info (
    product_id UUID PRIMARY KEY DEFAULT uuidv7(),
    name TEXT NOT NULL,
    price_cents INTEGER CHECK (price_cents >= 0) NOT NULL,  -- price in cents to avoid floating point issues
    date_created TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    -- I know I need a trigger but idk how to implement
    date_modified TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Seed data for products
INSERT INTO product_info (name, price_cents) VALUES
    -- Drinks (15)
    ('Coca-Cola', 159),
    ('Diet Coke', 165),
    ('Sprite', 149),
    ('Fanta Orange', 155),
    ('Dr Pepper', 189),
    ('Mountain Dew', 179),
    ('Pepsi', 157),
    ('Root Beer', 169),
    ('Lemonade', 225),
    ('Iced Tea', 185),
    ('Bottled Water', 129),
    ('Sparkling Water', 199),
    ('Gatorade', 259),
    ('Red Bull', 389),
    ('Monster Energy', 349);


SELECT * FROM product_info WHERE name ILIKE '%tea%';
