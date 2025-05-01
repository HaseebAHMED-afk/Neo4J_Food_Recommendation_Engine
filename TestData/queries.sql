-- public.dishes definition

-- Drop table

 DROP TABLE public.dishes;

CREATE TABLE public.dishes (
	id serial4 NOT NULL,
	"name" varchar NOT NULL,
	cuisine varchar NULL,
	CONSTRAINT dishes_pk PRIMARY KEY (id)
);


-- public.people definition

-- Drop table

 DROP TABLE public.people;

CREATE TABLE public.people (
	id serial4 NOT NULL,
	"name" varchar NOT NULL,
	age numeric NULL,
	CONSTRAINT people_pk PRIMARY KEY (id)
);


-- public.restaurant definition

-- Drop table

-- DROP TABLE public.restaurant;

CREATE TABLE public.restaurant (
	id serial4 NOT NULL,
	"name" varchar NOT NULL,
	cuisine varchar NULL,
	CONSTRAINT restaurant_pk PRIMARY KEY (id)
);


-- public.food_rating definition

-- Drop table

 DROP TABLE public.food_rating;

CREATE TABLE public.food_rating (
	id serial4 NOT NULL,
	restaurant_id int4 NOT NULL,
	user_id int4 NOT NULL,
	dish_id int4 NOT NULL,
	rating numeric NULL,
	CONSTRAINT food_rating_pk PRIMARY KEY (id)
);


-- public.food_rating foreign keys

ALTER TABLE public.food_rating ADD CONSTRAINT food_rating_dishes_fk FOREIGN KEY (dish_id) REFERENCES public.dishes(id);
ALTER TABLE public.food_rating ADD CONSTRAINT food_rating_people_fk FOREIGN KEY (user_id) REFERENCES public.people(id);
ALTER TABLE public.food_rating ADD CONSTRAINT food_rating_restaurant_fk FOREIGN KEY (restaurant_id) REFERENCES public.restaurant(id);




























