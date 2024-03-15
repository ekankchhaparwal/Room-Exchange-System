/*Table: ROOM */

CREATE TABLE ROOM (
    ROOM_ID      INT AUTO_INCREMENT PRIMARY KEY,
    BUILDING_NAME VARCHAR(30) NOT NULL,
    FLOOR_NO     DECIMAL(2,0) NOT NULL,
    WING         VARCHAR(5),
    ROOM_NUMBER  VARCHAR(5) NOT NULL
) AUTO_INCREMENT = 1000; -- Starting value set to 1000

DELIMITER $$
CREATE TRIGGER trigger_assign_room_id
BEFORE INSERT ON ROOM
FOR EACH ROW
BEGIN
    IF NEW.ROOM_ID IS NULL THEN
        SET NEW.ROOM_ID = (SELECT COALESCE(MAX(ROOM_ID), 0) + 1 FROM ROOM);
    END IF;
END$$
DELIMITER ;


/*comment on table "ROOM" is 'Table stores information about all the physical rooms';*/

/*Table: AUTHORIZATION */

CREATE TABLE AUTHORIZATION (
    EMAIL     VARCHAR(320) NOT NULL,
    PASSCODE VARCHAR(25) NOT NULL,
    CONSTRAINT AUTH_PK PRIMARY KEY (EMAIL)
);

/*Table: STUDENT*/

CREATE TABLE STUDENT (
    NAME                      VARCHAR(250) NOT NULL,
    EMAIL                     VARCHAR(320) NOT NULL,
    CONTACT_NUMBER            CHAR(10) NOT NULL,
    ROOM_ID                   INT NOT NULL,
    GENDER                    CHAR(1) NOT NULL,
    STUDENT_ID                CHAR(8) NOT NULL,
    ROOM_SWAP_AVAILABLE_FLAG  CHAR(1) DEFAULT 'Y',
    CONSTRAINT STUDENT_PK PRIMARY KEY (STUDENT_ID),
    CONSTRAINT EMAIL_FK FOREIGN KEY (EMAIL) REFERENCES AUTHORIZATION(EMAIL),
    CONSTRAINT UC_STUDENT UNIQUE (EMAIL, CONTACT_NUMBER),
    CONSTRAINT STUDENT_ROOM_FK FOREIGN KEY (ROOM_ID) REFERENCES ROOM(ROOM_ID),
    CONSTRAINT STUDENT_ROOM_SWAP_FLAG CHECK (ROOM_SWAP_AVAILABLE_FLAG IN ('Y', 'N')),
    CONSTRAINT CHECK_GENDER CHECK (GENDER IN ('M', 'F'))
);


/*comment on table "STUDENT" is 'Table contains personal and contact information about students';

comment on column "STUDENT"."ROOM_SWAP_AVAILABLE_FLAG" is 'Yes or No’. Default is Y */


/*Table: "AVAILABLE_ROOM"*/

CREATE TABLE AVAILABLE_ROOM (
    ROOM_ID     INT NOT NULL,
    STUDENT_ID  CHAR(8),
    ROOM_STATUS VARCHAR(15) NOT NULL,
    Description VARCHAR(250), 
    CONSTRAINT AVAIL_ROOM_FK FOREIGN KEY (ROOM_ID) REFERENCES ROOM (ROOM_ID),
    CONSTRAINT AVAIL_STUD_FK FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT (STUDENT_ID),
    CONSTRAINT AVAILABLE_ROOM_PK PRIMARY KEY (ROOM_ID, STUDENT_ID)
);

/*comment on table "AVAILABLE_ROOM" is 'Available Room table tracks the rooms that are currently available for new allocations or swaps';*/


/*Table: SWAP_REQUEST*/

CREATE TABLE SWAP_REQUEST (
    REQUEST_ID            INT AUTO_INCREMENT PRIMARY KEY,
    REQ_STUDENT_ID        CHAR(8) NOT NULL,
    REQ_TO_STUDENT_ID     CHAR(8) NOT NULL,
    REQ_ROOM_ID           INT NOT NULL,
    REQ_TO_ROOM_ID        INT NOT NULL,
    CONFIRM_AVAILABILITY  CHAR(8) NOT NULL,
    CONSTRAINT SWAP_REQ_STUD_ID_FK FOREIGN KEY (REQ_STUDENT_ID) REFERENCES STUDENT (STUDENT_ID),
    CONSTRAINT SWAP_TO_REQ_STUD_ID_FK FOREIGN KEY (REQ_TO_STUDENT_ID) REFERENCES STUDENT (STUDENT_ID),
    CONSTRAINT SWAP_REQ_ROOM_FK FOREIGN KEY (REQ_ROOM_ID) REFERENCES ROOM (ROOM_ID),
    CONSTRAINT SWAP_TO_REQ_ROOM_FK FOREIGN KEY (REQ_TO_ROOM_ID) REFERENCES ROOM (ROOM_ID),
    CONSTRAINT CHECK_CONFIRM_AVAILABILITY CHECK (CONFIRM_AVAILABILITY IN ('Pending', 'Accepted', 'Rejected'))
) AUTO_INCREMENT = 10000; -- Starting value set to 10000

DELIMITER $$
CREATE TRIGGER trigger_assign_request_id
BEFORE INSERT ON SWAP_REQUEST
FOR EACH ROW
BEGIN
    IF NEW.REQUEST_ID IS NULL THEN
        SET NEW.REQUEST_ID = (SELECT COALESCE(MAX(REQUEST_ID), 0) + 1 FROM SWAP_REQUEST);
    END IF;
END $$ 

DELIMITER ;