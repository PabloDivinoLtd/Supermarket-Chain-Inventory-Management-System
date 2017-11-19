DROP DATABASE DBMSMiniPro;

CREATE DATABASE DBMSMiniPro;

USE DBMSMiniPro;
CREATE TABLE COMPANY(CID INT PRIMARY KEY,CNAME VARCHAR(20) NOT NULL);

CREATE TABLE BRANCHES(
  BID INT NOT NULL, 
  LOC VARCHAR(20) NOT NULL, 
  CID INT NOT NULL, 
  PRIMARY KEY(BID,CID), 
  FOREIGN KEY(CID) REFERENCES COMPANY(CID) ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE DEPARTMENT( 
  DID INT NOT NULL, 
  BID INT NOT NULL, 
  CID INT NOT NULL, 
  DNAME VARCHAR(20) NOT NULL, 
  PRIMARY KEY(DID, BID, CID), 
  FOREIGN KEY(BID,CID) REFERENCES BRANCHES(BID,CID) ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE PRODUCT(
  PID INT NOT NULL, 
  DID INT NOT NULL,
  BID INT NOT NULL,
  CID INT NOT NULL,  
  PRODUCT_NAME VARCHAR(30) NOT NULL, 
  EXP_DATE DATE, 
  QUANTITY INT NOT NULL, 
  MIN_QTY INT NOT NULL, 
  PRICE_PER_UNIT FLOAT NOT NULL, 
  PRIMARY KEY(PID,BID,DID,CID), 
  FOREIGN KEY(DID,BID,CID) REFERENCES DEPARTMENT (DID,BID,CID) ON UPDATE CASCADE ON DELETE CASCADE );
  
CREATE TABLE PRODUCT_SOLD(
  PID INT NOT NULL, 
  DID INT NOT NULL, 
  BID INT NOT NULL,
  CID INT NOT NULL,       
  QUANTITY INT NOT NULL,  
  TOTAL_PRICE FLOAT ,
  TOTAL_PRICE_EXPIRED FLOAT, 
  PRIMARY KEY(PID,BID,DID,CID),  
  FOREIGN KEY(DID,BID,CID) REFERENCES DEPARTMENT (DID,BID,CID) ON UPDATE CASCADE ON DELETE CASCADE );

DELIMITER $$
CREATE TRIGGER EXPTRIG BEFORE INSERT ON PRODUCT 
FOR EACH ROW  
BEGIN 
IF NEW.EXP_DATE < CURDATE() 
THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PRODUCT ALREADY EXPIRED';
END IF; 
END;$$

CREATE TRIGGER QTYTRIG BEFORE UPDATE ON PRODUCT 
FOR EACH ROW  
BEGIN 
IF OLD.QUANTITY < OLD.MIN_QTY
THEN
SET NEW.QUANTITY = OLD.MIN_QTY;
END IF; 
END;$$

CREATE TRIGGER PSUTRIG BEFORE UPDATE ON PRODUCT_SOLD 
FOR EACH ROW  
BEGIN 
SET NEW.TOTAL_PRICE = NEW.QUANTITY*(SELECT PRICE_PER_UNIT FROM PRODUCT WHERE PID=NEW.PID AND DID=NEW.DID AND BID=NEW.BID AND CID=NEW.CID);
END;$$

CREATE TRIGGER PSITRIG BEFORE INSERT ON PRODUCT_SOLD 
FOR EACH ROW  
BEGIN 
SET NEW.TOTAL_PRICE = NEW.QUANTITY*(SELECT PRICE_PER_UNIT FROM PRODUCT WHERE PID=NEW.PID AND DID=NEW.DID AND BID=NEW.BID AND CID=NEW.CID);
END;$$

CREATE PROCEDURE EXP_10_P () 
BEGIN 
SELECT PID,BID,DID,CID  FROM PRODUCT WHERE EXP_DATE < DATE_ADD(CURDATE(), INTERVAL 10 DAY); 
END$$

CREATE PROCEDURE EXPP (IN COMPID INT) 
BEGIN 
SELECT PID,BID,DID FROM PRODUCT WHERE EXP_DATE = CURDATE() AND CID = COMPID; 
END$$

CREATE PROCEDURE EXP_DEC (IN COMPID INT) 
BEGIN 
UPDATE PRODUCT SET PRICE_PER_UNIT=PRICE_PER_UNIT*0.8 WHERE CID = COMPID AND EXP_DATE < DATE_ADD(CURDATE(), INTERVAL 10 DAY);
END$$


DELIMITER ;

INSERT INTO COMPANY VALUES (1, 'BigBazar');
INSERT INTO COMPANY VALUES (2, 'Spar');
INSERT INTO COMPANY VALUES (3, 'More'); 	

INSERT INTO BRANCHES VALUES (1, 'Kormangala', 1);
INSERT INTO BRANCHES VALUES (2, 'Whitefield', 1);
INSERT INTO BRANCHES VALUES (3, 'Shantinagar', 1);
INSERT INTO BRANCHES VALUES (1, 'Diary Circle', 2);
INSERT INTO BRANCHES VALUES (2, 'Sarjapur', 2);
INSERT INTO BRANCHES VALUES (1, 'Madiwala', 3);
INSERT INTO BRANCHES VALUES (2, 'Marathahalli', 3);
INSERT INTO BRANCHES VALUES (3, 'KR Puram', 3);

INSERT INTO DEPARTMENT VALUES (1,1,1,'FOOD AND BEVERAGES');
INSERT INTO DEPARTMENT VALUES (2,1,1,'HEALTH AND NUTRITION');
INSERT INTO DEPARTMENT VALUES (3,1,1,'CLOTHING');
INSERT INTO DEPARTMENT VALUES (4,1,1,'HOME');
INSERT INTO DEPARTMENT VALUES (5,1,1,'ELECTRIC&ELECTRONIC');

INSERT INTO DEPARTMENT VALUES (1,2,1,'FOOD AND BEVERAGES');
INSERT INTO DEPARTMENT VALUES (2,2,1,'HEALTH AND NUTRITION');
INSERT INTO DEPARTMENT VALUES (3,2,1,'CLOTHING');
INSERT INTO DEPARTMENT VALUES (4,2,1,'HOME');

INSERT INTO DEPARTMENT VALUES (1,3,1,'FOOD AND BEVERAGES');
INSERT INTO DEPARTMENT VALUES (2,3,1,'HEALTH AND NUTRITION');
INSERT INTO DEPARTMENT VALUES (3,3,1,'CLOTHING');

INSERT INTO DEPARTMENT VALUES (1,1,2,'FOOD AND BEVERAGES');
INSERT INTO DEPARTMENT VALUES (2,1,2,'HEALTH AND NUTRITION');
INSERT INTO DEPARTMENT VALUES (3,1,2,'CLOTHING');
INSERT INTO DEPARTMENT VALUES (4,1,2,'HOME');
INSERT INTO DEPARTMENT VALUES (5,1,2,'ELECTRIC&ELECTRONIC');

INSERT INTO DEPARTMENT VALUES (1,2,2,'FOOD AND BEVERAGES');
INSERT INTO DEPARTMENT VALUES (2,2,2,'HEALTH AND NUTRITION');
INSERT INTO DEPARTMENT VALUES (4,2,2,'HOME');
INSERT INTO DEPARTMENT VALUES (5,2,2,'ELECTRIC&ELECTRONIC');

INSERT INTO DEPARTMENT VALUES (1,1,3,'FOOD AND BEVERAGES');
INSERT INTO DEPARTMENT VALUES (2,1,3,'HEALTH AND NUTRITION');
INSERT INTO DEPARTMENT VALUES (3,1,3,'CLOTHING');
INSERT INTO DEPARTMENT VALUES (4,1,3,'HOME');
INSERT INTO DEPARTMENT VALUES (5,1,3,'ELECTRIC&ELECTRONIC');

INSERT INTO DEPARTMENT VALUES (1,2,3,'FOOD AND BEVERAGES');
INSERT INTO DEPARTMENT VALUES (2,2,3,'HEALTH AND NUTRITION');
INSERT INTO DEPARTMENT VALUES (4,2,3,'HOME');

INSERT INTO DEPARTMENT VALUES (1,3,3,'FOOD AND BEVERAGES');
INSERT INTO DEPARTMENT VALUES (2,3,3,'HEALTH AND NUTRITION');

INSERT INTO PRODUCT VALUES(1,4,1,1,'SCRUBBER',"2017-12-10",150,20,20);
INSERT INTO PRODUCT VALUES(2,4,1,1,'COTTON MOP',"2018-1-10",50,10,200);
INSERT INTO PRODUCT VALUES(3,4,1,1,'SOUP BOWL',"2018-12-10",250,30,120);
INSERT INTO PRODUCT VALUES(4,4,1,1,'CROCKERY PLATE',"2018-12-10",250,30,220);
INSERT INTO PRODUCT VALUES(5,4,1,1,'PLASTIC TRAY',"2018-12-10",50,10,20);

INSERT INTO PRODUCT VALUES(1,1,1,1,'ENERGY DRINK',"2018-1-1",250,50,70);
INSERT INTO PRODUCT VALUES(2,1,1,1,'HEALTH DRINK',"2017-12-10",50,10,200);
INSERT INTO PRODUCT VALUES(3,1,1,1,'SOFT DRINK',"2017-12-31",500,70,50);
INSERT INTO PRODUCT VALUES(4,1,1,1,'TEA & COFFEE',"2018-3-10",500,70,120);
INSERT INTO PRODUCT VALUES(5,1,1,1,'MILK & DIARY',"2017-12-1",200,40,20);
INSERT INTO PRODUCT VALUES(6,1,1,1,'BREAD',"2017-12-1",75,10,30);

INSERT INTO PRODUCT VALUES(1,3,1,1,'JEANS (M)',NULL,100,50,1300);
INSERT INTO PRODUCT VALUES(2,3,1,1,'JEANS (F)',NULL,75,40,1300);
INSERT INTO PRODUCT VALUES(3,3,1,1,'T SHIRTS (M)',NULL,500,200,600);
INSERT INTO PRODUCT VALUES(4,3,1,1,'T SHIRTS(F)',NULL,700,250,500);
INSERT INTO PRODUCT VALUES(5,3,1,1,'BELTS',NULL,100,30,400);

INSERT INTO PRODUCT VALUES(1,2,1,1,'SANITIZER',"2018-11-1",70,20,60);
INSERT INTO PRODUCT VALUES(2,2,1,1,'LIP CARE',"2018-01-1",50,10,70);
INSERT INTO PRODUCT VALUES(3,2,1,1,'CALCIUM TABS',"2018-2-1",70,20,200);
INSERT INTO PRODUCT VALUES(4,2,1,1,'INSECT KILLER',"2017-12-15",50,20,300);

INSERT INTO PRODUCT VALUES(1,5,1,1,'BATTERY',"2018-05-1",100,30,15);
INSERT INTO PRODUCT VALUES(2,5,1,1,'LAMP',"2018-05-1",50,10,200);
INSERT INTO PRODUCT VALUES(3,5,1,1,'IRON',"2018-09-1",100,30,1000);
INSERT INTO PRODUCT VALUES(4,5,1,1,'FAN',"2018-09-1",100,20,1500);
INSERT INTO PRODUCT VALUES(5,5,1,1,'COOLER',"2018-05-1",50,10,10000);


INSERT INTO PRODUCT VALUES(1,4,2,1,'SCRUBBER',"2017-12-10",100,10,20);
INSERT INTO PRODUCT VALUES(3,4,2,1,'SOUP BOWL',NULL,350,20,150);
INSERT INTO PRODUCT VALUES(4,4,2,1,'CROCKERY PLATE',NULL,200,30,220);
INSERT INTO PRODUCT VALUES(5,4,2,1,'PLASTIC TRAY',NULL,60,20,50);

INSERT INTO PRODUCT VALUES(1,1,2,1,'ENERGY DRINK',"2017-12-15",200,50,70);
INSERT INTO PRODUCT VALUES(2,1,2,1,'HEALTH DRINK',"2017-12-25",50,10,200);
INSERT INTO PRODUCT VALUES(3,1,2,1,'SOFT DRINK',"2017-12-31",500,70,60);
INSERT INTO PRODUCT VALUES(4,1,2,1,'TEA & COFFEE',"2018-2-10",200,40,120);
INSERT INTO PRODUCT VALUES(5,1,2,1,'MILK & DIARY',"2017-12-19",100,20,25);
INSERT INTO PRODUCT VALUES(6,1,2,1,'BREAD',"2017-12-1",30,5,30);

INSERT INTO PRODUCT VALUES(1,3,2,1,'JEANS (M)',NULL,150,40,1200);
INSERT INTO PRODUCT VALUES(2,3,2,1,'JEANS (F)',NULL,85,30,1250);
INSERT INTO PRODUCT VALUES(3,3,2,1,'T SHIRTS (M)',NULL,500,200,500);
INSERT INTO PRODUCT VALUES(4,3,2,1,'T SHIRTS(F)',NULL,700,250,600);

INSERT INTO PRODUCT VALUES(1,2,2,1,'SANITIZER',"2018-11-15",70,20,60);
INSERT INTO PRODUCT VALUES(2,2,2,1,'LIP CARE',"2018-01-19",50,10,70);
INSERT INTO PRODUCT VALUES(4,2,2,1,'INSECT KILLER',"2017-12-1",50,20,300);

INSERT INTO PRODUCT VALUES(1,1,3,1,'ENERGY DRINK',"2018-2-1",150,60,75);
INSERT INTO PRODUCT VALUES(3,1,3,1,'SOFT DRINK',"2017-11-30",200,20,55);
INSERT INTO PRODUCT VALUES(4,1,3,1,'TEA & COFFEE',"2018-1-10",300,60,115);
INSERT INTO PRODUCT VALUES(5,1,3,1,'MILK & DIARY',"2017-11-25",300,30,15);
INSERT INTO PRODUCT VALUES(6,1,3,1,'BREAD',"2017-12-1",85,10,30);

INSERT INTO PRODUCT VALUES(1,3,3,1,'JEANS (M)',NULL,100,50,1400);
INSERT INTO PRODUCT VALUES(2,3,3,1,'JEANS (F)',NULL,65,40,1400);
INSERT INTO PRODUCT VALUES(3,3,3,1,'T SHIRTS (M)',NULL,400,200,500);
INSERT INTO PRODUCT VALUES(4,3,3,1,'T SHIRTS(F)',NULL,600,250,400);
INSERT INTO PRODUCT VALUES(5,3,3,1,'BELTS',NULL,100,40,400);

INSERT INTO PRODUCT VALUES(1,2,3,1,'SANITIZER',"2018-12-1",60,20,60);
INSERT INTO PRODUCT VALUES(2,2,3,1,'LIP CARE',"2018-02-1",40,10,70);
INSERT INTO PRODUCT VALUES(3,2,3,1,'CALCIUM TABS',"2018-1-1",50,20,200);
INSERT INTO PRODUCT VALUES(4,2,3,1,'INSECT KILLER',"2017-11-15",60,20,300);

INSERT INTO PRODUCT VALUES(1,4,1,2,'SCRUBBER',"2017-11-10",150,10,20);
INSERT INTO PRODUCT VALUES(2,4,1,2,'COTTON MOP',"2017-12-10",50,20,200);
INSERT INTO PRODUCT VALUES(3,4,1,2,'SOUP BOWL',"2017-11-30",250,40,120);
INSERT INTO PRODUCT VALUES(5,4,1,2,'PLASTIC TRAY',"2018-2-1",50,20,20);

INSERT INTO PRODUCT VALUES(2,1,1,2,'HEALTH DRINK',"2017-12-10",50,10,300);
INSERT INTO PRODUCT VALUES(3,1,1,2,'SOFT DRINK',"2017-12-31",500,50,20);
INSERT INTO PRODUCT VALUES(4,1,1,2,'TEA & COFFEE',"2018-3-10",500,40,150);
INSERT INTO PRODUCT VALUES(5,1,1,2,'MILK & DIARY',"2017-12-1",200,60,20);
INSERT INTO PRODUCT VALUES(6,1,1,2,'BREAD',"2017-12-1",75,10,40);

INSERT INTO PRODUCT VALUES(2,3,1,2,'JEANS (F)',NULL,75,20,1100);
INSERT INTO PRODUCT VALUES(3,3,1,2,'T SHIRTS (M)',NULL,500,300,300);
INSERT INTO PRODUCT VALUES(4,3,1,2,'T SHIRTS(F)',NULL,700,150,300);
INSERT INTO PRODUCT VALUES(5,3,1,2,'BELTS',NULL,100,10,300);

INSERT INTO PRODUCT VALUES(1,2,1,2,'SANITIZER',"2017-12-1",70,20,50);
INSERT INTO PRODUCT VALUES(3,2,1,2,'CALCIUM TABS',"2017-12-1",70,30,230);
INSERT INTO PRODUCT VALUES(4,2,1,2,'INSECT KILLER',"2018-12-15",50,10,330);

INSERT INTO PRODUCT VALUES(1,5,1,2,'BATTERY',"2018-03-1",100,10,25);
INSERT INTO PRODUCT VALUES(2,5,1,2,'LAMP',"2018-01-1",50,20,300);
INSERT INTO PRODUCT VALUES(4,5,1,2,'FAN',"2018-12-1",100,15,1200);
INSERT INTO PRODUCT VALUES(5,5,1,2,'COOLER',"2018-06-1",50,5,9000);



INSERT INTO PRODUCT VALUES(2,4,2,2,'COTTON MOP',"2017-12-20",30,20,200);
INSERT INTO PRODUCT VALUES(3,4,2,2,'SOUP BOWL',"2017-12-30",230,40,120);
INSERT INTO PRODUCT VALUES(5,4,2,2,'PLASTIC TRAY',"2018-2-25",20,20,20);

INSERT INTO PRODUCT VALUES(4,1,2,2,'TEA & COFFEE',"2018-2-10",600,40,150);
INSERT INTO PRODUCT VALUES(5,1,2,2,'MILK & DIARY',"2017-11-30",200,60,20);
INSERT INTO PRODUCT VALUES(6,1,2,2,'BREAD',"2017-11-30",65,10,40);


INSERT INTO PRODUCT VALUES(1,2,2,2,'SANITIZER',"2018-12-1",72,20,50);
INSERT INTO PRODUCT VALUES(3,2,2,2,'CALCIUM TABS',"2018-1-1",70,50,230);
INSERT INTO PRODUCT VALUES(4,2,2,2,'INSECT KILLER',"2018-1-15",50,60,330);

INSERT INTO PRODUCT VALUES(1,5,2,2,'BATTERY',"2018-03-1",100,20,25);
INSERT INTO PRODUCT VALUES(2,5,2,2,'LAMP',"2018-01-1",50,10,300);
INSERT INTO PRODUCT VALUES(4,5,2,2,'FAN',"2018-12-1",100,25,1400);



INSERT INTO PRODUCT VALUES(1,4,1,3,'SCRUBBER',"2018-7-10",150,20,20);
INSERT INTO PRODUCT VALUES(2,4,1,3,'COTTON MOP',"2017-11-30",50,10,200);
INSERT INTO PRODUCT VALUES(3,4,1,3,'SOUP BOWL',"2018-1-10",250,30,420);
INSERT INTO PRODUCT VALUES(4,4,1,3,'CROCKERY PLATE',"2018-1-10",250,30,170);
INSERT INTO PRODUCT VALUES(5,4,1,3,'PLASTIC TRAY',"2018-1-10",50,10,50);


INSERT INTO PRODUCT VALUES(2,1,1,3,'HEALTH DRINK',"2018-1-10",50,10,240);
INSERT INTO PRODUCT VALUES(3,1,1,3,'SOFT DRINK',"2017-12-31",500,70,55);
INSERT INTO PRODUCT VALUES(4,1,1,3,'TEA & COFFEE',"2018-3-10",500,70,160);
INSERT INTO PRODUCT VALUES(5,1,1,3,'MILK & DIARY',"2017-11-30",200,40,30);


INSERT INTO PRODUCT VALUES(1,3,1,3,'JEANS (M)',NULL,100,50,1230);
INSERT INTO PRODUCT VALUES(2,3,1,3,'JEANS (F)',NULL,75,40,1230);
INSERT INTO PRODUCT VALUES(3,3,1,3,'T SHIRTS (M)',NULL,500,200,700);
INSERT INTO PRODUCT VALUES(5,3,1,3,'BELTS',NULL,100,30,350);

INSERT INTO PRODUCT VALUES(1,2,1,3,'SANITIZER',"2018-11-1",70,20,50);
INSERT INTO PRODUCT VALUES(4,2,1,3,'INSECT KILLER',"2017-12-15",50,20,250);

INSERT INTO PRODUCT VALUES(1,5,1,3,'BATTERY',"2018-05-1",100,30,35);
INSERT INTO PRODUCT VALUES(2,5,1,3,'LAMP',"2018-05-1",50,10,220);
INSERT INTO PRODUCT VALUES(3,5,1,3,'IRON',"2018-09-1",100,30,1200);


INSERT INTO PRODUCT VALUES(3,4,2,3,'SOUP BOWL',"2017-11-28",250,10,320);
INSERT INTO PRODUCT VALUES(4,4,2,3,'CROCKERY PLATE',"2017-12-10",250,10,120);
INSERT INTO PRODUCT VALUES(5,4,2,3,'PLASTIC TRAY',"2017-12-10",50,10,40);


INSERT INTO PRODUCT VALUES(2,1,2,3,'HEALTH DRINK',"2017-12-10",50,20,140);
INSERT INTO PRODUCT VALUES(3,1,2,3,'SOFT DRINK',"2018-1-3",500,50,65);
INSERT INTO PRODUCT VALUES(4,1,2,3,'TEA & COFFEE',"2018-6-10",500,20,170);
INSERT INTO PRODUCT VALUES(5,1,2,3,'MILK & DIARY',"2017-12-30",200,20,32);

INSERT INTO PRODUCT VALUES(1,2,2,3,'SANITIZER',"2018-12-1",70,40,40);
INSERT INTO PRODUCT VALUES(4,2,2,3,'INSECT KILLER',"2017-11-25",50,10,200);

INSERT INTO PRODUCT VALUES(1,1,3,3,'ENERGY DRINK',"2018-2-1",250,50,75);
INSERT INTO PRODUCT VALUES(2,1,3,3,'HEALTH DRINK',"2017-11-30",50,10,205);
INSERT INTO PRODUCT VALUES(3,1,3,3,'SOFT DRINK',"2018-1-3",500,70,55);
INSERT INTO PRODUCT VALUES(4,1,3,3,'TEA & COFFEE',"2018-4-10",500,70,125);
INSERT INTO PRODUCT VALUES(5,1,3,3,'MILK & DIARY',"2017-11-30",200,40,25);
INSERT INTO PRODUCT VALUES(6,1,3,3,'BREAD',"2017-11-30",75,10,35);

INSERT INTO PRODUCT VALUES(1,2,3,3,'SANITIZER',"2018-6-1",70,20,50);
INSERT INTO PRODUCT VALUES(2,2,3,3,'LIP CARE',"2018-2-1",50,10,60);
INSERT INTO PRODUCT VALUES(3,2,3,3,'CALCIUM TABS',"2018-1-1",70,20,230);
INSERT INTO PRODUCT VALUES(4,2,3,3,'INSECT KILLER',"2018-12-15",50,20,200);

INSERT INTO PRODUCT_SOLD VALUES(1,4,1,1,20,NULL,50);
INSERT INTO PRODUCT_SOLD VALUES(2,4,1,1,10,NULL,200);
INSERT INTO PRODUCT_SOLD VALUES(3,4,1,1,20,NULL,120);

INSERT INTO PRODUCT_SOLD VALUES(4,1,1,1,5,NULL,0);
INSERT INTO PRODUCT_SOLD VALUES(5,1,1,1,20,NULL,00);
INSERT INTO PRODUCT_SOLD VALUES(6,1,1,1,7,NULL,0);

INSERT INTO PRODUCT_SOLD VALUES(3,3,1,1,5,NULL,0);
INSERT INTO PRODUCT_SOLD VALUES(4,3,1,1,7,NULL,0);

INSERT INTO PRODUCT_SOLD VALUES(1,2,1,1,10,NULL,120);
INSERT INTO PRODUCT_SOLD VALUES(2,2,1,1,20,NULL,140);
INSERT INTO PRODUCT_SOLD VALUES(1,5,1,1,10,NULL,45);
INSERT INTO PRODUCT_SOLD VALUES(2,5,1,1,5,NULL,400);
INSERT INTO PRODUCT_SOLD VALUES(4,4,2,1,20,NULL,220);
INSERT INTO PRODUCT_SOLD VALUES(5,4,2,1,6,NULL,500);
INSERT INTO PRODUCT_SOLD VALUES(2,1,2,1,5,NULL,200);
INSERT INTO PRODUCT_SOLD VALUES(3,1,2,1,10,NULL,120);
INSERT INTO PRODUCT_SOLD VALUES(4,1,2,1,20,NULL,240);
