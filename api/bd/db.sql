
CREATE TABLE houses(
    id  varchar(100) PRIMARY KEY,
    admin_id varchar(100),
    description varchar(100),
    price varchar(10),
    rooms int ,
    surface varchar(10),
    type varchar(20),
    location varchar(30),
    ville varchar(50),
    region varchar(50)
);

CREATE TABLE images(
    id  varchar(100) PRIMARY KEY,
    house_id varchar(100),
    type varchar(20),
    url varchar(100)
);

CREATE TABLE favorite(
    id  varchar(100) PRIMARY KEY,
    user_id varchar(100),
    house_id varchar(100)
);