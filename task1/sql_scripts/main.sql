
CREATE TABLE htask.countries (
  country_id SERIAL  PRIMARY KEY,
  name varchar NOT NULL
);

INSERT INTO htask.countries ("name") VALUES('Australia');

CREATE TABLE htask.states (
  state_id SERIAL PRIMARY KEY,
  state varchar NOT NULL,
  country_id integer NOT null,
  CONSTRAINT fk_states_countries FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

INSERT INTO htask.states ("state", "country_id") VALUES('New South Wales', 1);
INSERT INTO htask.states ("state", "country_id") VALUES('VIC', 1);
INSERT INTO htask.states ("state", "country_id") VALUES('QLD', 1);
INSERT INTO htask.states ("state", "country_id") VALUES('Victoria', 1);
INSERT INTO htask.states ("state", "country_id") VALUES('NSW', 1);

CREATE TABLE htask.postcodes (
  postcode_id SERIAL PRIMARY KEY,
  postcode varchar NOT NULL,
  state_id integer NOT null,
  CONSTRAINT fk_postcodes_states FOREIGN KEY (state_id) REFERENCES htask.states(state_id)
);

CREATE TABLE htask.job_industry_category (
  job_industry_category_id SERIAL PRIMARY KEY,
  name varchar NOT null  
);

INSERT INTO htask.job_industry_category ("name") VALUES('Health');
INSERT INTO htask.job_industry_category ("name") VALUES('Financial Services');
INSERT INTO htask.job_industry_category ("name") VALUES('Property');
INSERT INTO htask.job_industry_category ("name") VALUES('IT');
INSERT INTO htask.job_industry_category ("name") VALUES('n/a');
INSERT INTO htask.job_industry_category ("name") VALUES('Retail');
INSERT INTO htask.job_industry_category ("name") VALUES('Argiculture');
INSERT INTO htask.job_industry_category ("name") VALUES('Manufacturing');

CREATE TABLE htask.wealth_segments (
  wealth_segment_id SERIAL PRIMARY KEY,
  name varchar NOT NULL
);

INSERT INTO htask.wealth_segments ("name") VALUES('Mass Customer');
INSERT INTO htask.wealth_segments ("name") VALUES('Affluent Customer');
INSERT INTO htask.wealth_segments ("name") VALUES('High Net Worth');

CREATE TABLE htask.customer (
  customer_id integer PRIMARY KEY,
  job_industry_category_id integer NOT NULL,
  postcode_id integer NOT NULL,
  first_name varchar NOT NULL,
  gender char(1) NOT NULL,
  owns_car boolean NOT NULL,
  deceased_indicator char(1) NOT NULL,
  property_valuation int NOT NULL,
  wealth_segment_id integer NOT NULL,
  address varchar not NULL,
  last_name varchar,
  DOB date,
  job_title varchar,
  CONSTRAINT fk_customer_job_industry_category FOREIGN KEY (job_industry_category_id) 
  	REFERENCES htask.job_industry_category(job_industry_category_id),
  CONSTRAINT fk_customer_postcodes FOREIGN KEY (postcode_id) 
  	REFERENCES htask.postcodes(postcode_id),
  CONSTRAINT fk_customer_wealth_segment FOREIGN KEY (wealth_segment_id) 
  	REFERENCES htask.wealth_segments(wealth_segment_id)  
);

CREATE TABLE htask.brand (
  brand_id SERIAL PRIMARY KEY,
  name varchar NOT NULL
);

CREATE TABLE htask.product_line (
  product_line_id SERIAL PRIMARY KEY,
  name varchar NOT NULL
);

CREATE TABLE htask.product_class (
  product_class_id SERIAL PRIMARY KEY,
  name varchar NOT NULL
);

CREATE TABLE htask.product_size (
  product_size_id SERIAL PRIMARY KEY,
  name varchar NOT NULL
);

INSERT INTO htask.product_line ("name") VALUES('Standard');
INSERT INTO htask.product_line ("name") VALUES('Road');
INSERT INTO htask.product_line ("name") VALUES('Mountain');
INSERT INTO htask.product_line ("name") VALUES('Touring');

INSERT INTO htask.product_class ("name") VALUES('high');
INSERT INTO htask.product_class ("name") VALUES('low');
INSERT INTO htask.product_class ("name") VALUES('medium');

INSERT INTO htask.product_size ("name") VALUES('medium');
INSERT INTO htask.product_size ("name") VALUES('large');
INSERT INTO htask.product_size ("name") VALUES('small');

CREATE TABLE htask.product (
  xpk_product_id SERIAL PRIMARY KEY,
  product_line_id integer not NULL,
  product_size_id integer not NULL,
  product_class_id integer not NULL,
  brand_id integer not NULL,
  standard_cost decimal NOT null,
  CONSTRAINT fk_product_product_line FOREIGN KEY (product_line_id) REFERENCES htask.product_line(product_line_id),
  CONSTRAINT fk_product_product_size FOREIGN KEY (product_size_id) REFERENCES htask.product_size(product_size_id),
  CONSTRAINT fk_product_product_class FOREIGN KEY (product_class_id) REFERENCES htask.product_class(product_class_id),
  CONSTRAINT fk_product_brand FOREIGN KEY (brand_id) REFERENCES htask.brand(brand_id)
); 

CREATE TABLE htask.transaction (
  transaction_id integer PRIMARY KEY,
  customer_id integer NOT NULL,
  xpk_product_id integer,
  product_id integer not NULL,
  transaction_date date NOT NULL,
  online_order char(5) NOT NULL,
  order_status varchar NOT NULL,
  list_price decimal NOT null,
  CONSTRAINT fk_transaction_customer FOREIGN KEY (customer_id) REFERENCES htask.customer(customer_id),
  CONSTRAINT fk_transaction_product FOREIGN KEY (xpk_product_id) REFERENCES htask.product(xpk_product_id)
);





































