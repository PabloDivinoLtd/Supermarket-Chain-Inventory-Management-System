DROP DATABASE DBMSMiniPro;

CREATE DATABASE DBMSMiniPro;

USE DBMSMiniPro;

CREATE TABLE BRANCHES(BID INT PRIMARY KEY, LOC VARCHAR(20) NOT NULL);

CREATE TABLE DEPARTMENT(DID INT NOT NULL, BID INT NOT NULL, DNAME VARCHAR(20) NOT NULL, PRIMARY KEY(DID, BID), FOREIGN KEY(BID) REFERENCES BRANCHES(BID) ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE PRODUCT(
  PID INT NOT NULL, 
  DID INT NOT NULL, 
  BID INT NOT NULL, 
  PRODUCT_NAME VARCHAR(30) NOT NULL, 
  EXP_DATE DATE NOT NULL, 
  QUANTITY INT NOT NULL, 
  MIN_QTY INT NOT NULL, 
  PRICE_PER_UNIT FLOAT NOT NULL, 
  PRIMARY KEY(PID,BID,DID), 
  FOREIGN KEY(BID,DID) REFERENCES DEPARTMENT(BID,DID) ON UPDATE CASCADE ON DELETE CASCADE );

