Clear Screen;

SET SERVEROUTPUT ON;
SET VERIFY OFF;

@"C:\Users\saqla\OneDrive\Desktop\Files\CSE-4126\Project\SQL Flies\Site\CustomerInfo.sql";

-------DECLARING CSE4126DDS1 TRIGGER----------
CREATE OR REPLACE TRIGGER CSE4126DDS1 
AFTER INSERT OR UPDATE
ON CustomerInfo
DECLARE
BEGIN
	DBMS_OUTPUT.PUT_LINE('------------------------');
	DBMS_OUTPUT.PUT_LINE('Trigger Message: Customer Credit Card Eligibility predicted!');
	DBMS_OUTPUT.PUT_LINE('------------------------');
END;
/


-------DECLARING CSEAUST129Site PACKAGE----------
CREATE OR REPLACE PACKAGE CSEAUST129Site AS
	
	FUNCTION Card_Eligibility_Prediction(
        Test_EstdIncome IN OUT NUMBER, Test_HBalance IN OUT NUMBER, Test_CScore IN OUT NUMBER, 
        Test_RScore     IN OUT NUMBER, Test_CreditVal IN OUT NUMBER, Prediction2 IN OUT NUMBER, 
        b0 IN OUT NUMBER, b1 IN OUT NUMBER, b2 IN OUT NUMBER, b3 IN OUT NUMBER, b4 IN OUT NUMBER, b5 IN OUT NUMBER, 
        Max1 IN OUT NUMBER, Max2 IN OUT NUMBER, Max3 IN OUT NUMBER, Max4 IN OUT NUMBER, Max5 IN OUT NUMBER, 
        Min1 IN OUT NUMBER, Min2 IN OUT NUMBER, Min3 IN OUT NUMBER, Min4 IN OUT NUMBER, Min5 IN OUT NUMBER,
        TestingUserID IN NUMBER
    )
	RETURN NUMBER;
	
END CSEAUST129Site;
/


--------IMPLEMENTING THE BODY OF CSEAUST129Site PACKAGE-------- 
CREATE OR REPLACE PACKAGE BODY CSEAUST129Site AS

FUNCTION Card_Eligibility_Prediction(
        Test_EstdIncome IN OUT NUMBER, Test_HBalance IN OUT NUMBER, Test_CScore IN OUT NUMBER, 
        Test_RScore     IN OUT NUMBER, Test_CreditVal IN OUT NUMBER, Prediction2 IN OUT NUMBER, 
        b0 IN OUT NUMBER, b1 IN OUT NUMBER, b2 IN OUT NUMBER, b3 IN OUT NUMBER, b4 IN OUT NUMBER, b5 IN OUT NUMBER, 
        Max1 IN OUT NUMBER, Max2 IN OUT NUMBER, Max3 IN OUT NUMBER, Max4 IN OUT NUMBER, Max5 IN OUT NUMBER, 
        Min1 IN OUT NUMBER, Min2 IN OUT NUMBER, Min3 IN OUT NUMBER, Min4 IN OUT NUMBER, Min5 IN OUT NUMBER,
        TestingUserID IN NUMBER
    )
	RETURN NUMBER
    IS

    BEGIN

        Select Customer_EstdIncome,Customer_HBalance,Customer_CScore,Customer_RScore,Customer_CreditVal
        Into Test_EstdIncome,Test_HBalance,Test_CScore,Test_RScore,Test_CreditVal
        From CustomerInfo@server1 Where Customer_ID = TestingUserID;

        DBMS_OUTPUT.PUT_LINE('_________________________');

        Prediction2 := b0 + 
        b1 * ((Test_EstdIncome-Min1)/(Max1 - Min1)) + 
        b2 * ((Test_HBalance-Min2)/(Max2 - Min2)) + 
        b3 * ((Test_CScore-Min3)/(Max3 - Min3)) + 
        b4 * ((Test_RScore-Min4)/(Max4 - Min4)) +
        b5 * ((Test_CreditVal-Min5)/(Max5 - Min5));

        DBMS_OUTPUT.PUT_LINE('Value predicted by the model : 0' || Prediction2);

        IF Prediction2 < 0.5 THEN
            RETURN 0;
        ELSE
            RETURN 1;
        END IF;  

    END Card_Eligibility_Prediction;

	
END CSEAUST129Site;
/





DECLARE

	C_Name VARCHAR2(50);
	C_Age NUMBER;
	C_ID NUMBER := 1001;
	
	C_EstdIncome NUMBER;
    C_HBalance NUMBER;
    C_CScore NUMBER;
    C_RScore NUMBER;
    C_CreditVal NUMBER;

	OfferStatus NUMBER := 0;
    Prediction2 NUMBER := 0;
	
	Max1 NUMBER;
    Max2 NUMBER;
    Max3 NUMBER;
    Max4 NUMBER;
    Max5 NUMBER;

    Min1 NUMBER;
    Min2 NUMBER;
    Min3 NUMBER;
    Min4 NUMBER;
    Min5 NUMBER;
	
	Test_EstdIncome NUMBER;
    Test_HBalance NUMBER;
    Test_CScore NUMBER;
    Test_RScore NUMBER;
    Test_CreditVal NUMBER;
	
	b0 NUMBER := 0;
    b1 NUMBER := 0;
    b2 NUMBER := 0;
    b3 NUMBER := 0;
    b4 NUMBER := 0;
    b5 NUMBER := 0;
	
    TestingUserID NUMBER := -1;
	
	Error_Negative_Age EXCEPTION;
	
BEGIN
	
	C_Name := '&Customer_Name';
	C_Age := &Customer_Age;
	
	IF C_Age < 0 THEN
		RAISE Error_Negative_Age;
	END IF;
	
	
	FOR X IN (SELECT * FROM CustomerInfo@server1) LOOP
		C_ID := C_ID + 1;
	END LOOP;
			
	/*C_EstdIncome := Estimated_Income;
    C_HBalance := Holding_Balance;
    C_CScore := Credit_Score;
    C_RScore := Risk_Score;
    C_CreditVal := Credit_Value;*/
	
	
	-- Data for not eligible
	C_EstdIncome := 51222.471;
    C_HBalance := 4;
    C_CScore := 606;
    C_RScore := 586.605795;
    C_CreditVal := 24.939219;
	
	
	-- Data for eligible
	/*C_EstdIncome := 87710.59301;
    C_HBalance := 5;
    C_CScore := 559;
    C_RScore := 740.578256;
    C_CreditVal := 23.936051;*/
	
	
	DBMS_OUTPUT.PUT_LINE('------------------------------');
	DBMS_OUTPUT.PUT_LINE('------------------------------');
	DBMS_OUTPUT.PUT_LINE('------------------------------');
	DBMS_OUTPUT.PUT_LINE('------------------------------');
	
	INSERT INTO CustomerInfo VALUES(C_ID,C_Name,C_Age,0);
	
	UPDATE CurrentUserView@server1 SET View_B = C_ID WHERE View_A = 1;
	
	INSERT INTO CustomerInfo@server1 VALUES(C_ID,C_EstdIncome,C_HBalance,C_CScore,C_RScore,C_CreditVal,0);
	
	COMMIT;	
	
	
	
	Prediction2 := -1;

    Select View_B Into TestingUserID From CurrentUserView@server1 Where View_A = 1;
	
	DBMS_OUTPUT.PUT_LINE('So current user id : ' || TestingUserID);
	
	Select FNMax1, FNMax2, FNMax3, FNMax4, FNMax5, FNMin1, FNMin2, FNMin3, FNMin4, FNMin5, CoEfb0, CoEfb1, CoEfb2, CoEfb3,
    CoEfb4, CoEfb5 Into Max1, Max2, Max3, Max4, Max5, Min1, Min2, Min3, Min4, Min5,b0, b1, b2, b3, b4, b5 
	From TestingDataset@server1 Where TID = 1;

    Prediction2 := CSEAUST129Site.Card_Eligibility_Prediction(C_EstdIncome, C_HBalance, C_CScore, C_RScore, 
    C_CreditVal, Prediction2, b0, b1, b2, b3, b4, b5, Max1, Max2, Max3, Max4, Max5, Min1, Min2, Min3, Min4, Min5,
    TestingUserID);
    
    DBMS_OUTPUT.PUT_LINE('_________________________');

    IF Prediction2 < 0 THEN
        DBMS_OUTPUT.PUT_LINE('No user data found!');
    ELSE 

	    UPDATE CustomerInfo SET Customer_CreditCardOffer = 1 WHERE Customer_ID = TestingUserID;

        Commit;
		
		--DBMS_OUTPUT.PUT_LINE('The class predicted by the model: ' || Prediction2);
		
		
		IF Prediction2 = 1 THEN
			DBMS_OUTPUT.PUT_LINE('Congratulations Mr./Ms. ' || C_Name || ', you are eligible for having a Credit Card!');
			UPDATE CustomerInfo@server1 SET Customer_CreditCardStatus = 1 WHERE Customer_ID = C_ID;
			UPDATE CustomerInfo SET Customer_CreditCardOffer = 1 WHERE Customer_ID = C_ID;
			COMMIT;
		ELSIF Prediction2 = 0 THEN
			DBMS_OUTPUT.PUT_LINE('Sorry Mr./Ms. ' || C_Name || ', you are currently not eligible for having a Credit Card!');
			UPDATE CustomerInfo@server1 SET Customer_CreditCardStatus = 0 WHERE Customer_ID = C_ID;
			UPDATE CustomerInfo SET Customer_CreditCardOffer = 0 WHERE Customer_ID = C_ID;
			COMMIT;
		END IF;
		
    END IF;

    DBMS_OUTPUT.PUT_LINE('_________________________');
		
	--SELECT Customer_CreditCardOffer INTO OfferStatus FROM CustomerInfo WHERE Customer_ID = C_ID;
	
	EXCEPTION
		WHEN Error_Negative_Age THEN
			DBMS_OUTPUT.PUT_LINE('Age cannot be negative!');
END;
/