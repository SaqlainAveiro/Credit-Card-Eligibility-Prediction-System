Clear Screen;

SET SERVEROUTPUT ON;
SET VERIFY OFF;

@"F:\My Pictures\#Saqlain\#AUST\Aust-Files\#Programming\Academic\7. Spring-2021 4.1\CSE-4126 (DDS Lab)\Project\SQL Files\Server\CreditCardDataset.sql";
@"F:\My Pictures\#Saqlain\#AUST\Aust-Files\#Programming\Academic\7. Spring-2021 4.1\CSE-4126 (DDS Lab)\Project\SQL Files\Server\FNCreditCardDataset.sql";
@"F:\My Pictures\#Saqlain\#AUST\Aust-Files\#Programming\Academic\7. Spring-2021 4.1\CSE-4126 (DDS Lab)\Project\SQL Files\Server\CustomerInfo.sql";
@"F:\My Pictures\#Saqlain\#AUST\Aust-Files\#Programming\Academic\7. Spring-2021 4.1\CSE-4126 (DDS Lab)\Project\SQL Files\Server\CurrentUser.sql";
@"F:\My Pictures\#Saqlain\#AUST\Aust-Files\#Programming\Academic\7. Spring-2021 4.1\CSE-4126 (DDS Lab)\Project\SQL Files\Server\TestingDataset.sql";


-------DECLARING CSE4126DDS TRIGGER----------
CREATE OR REPLACE TRIGGER CSE4126DDS 
AFTER UPDATE
ON CustomerInfo
DECLARE
BEGIN
	DBMS_OUTPUT.PUT_LINE('Customer Credit Card Eligibility Testing!');
	DBMS_OUTPUT.PUT_LINE('------------------------');
END;
/


CREATE OR REPLACE VIEW CurrentUserView(View_A, View_B) AS
SELECT CU.SL, CU.UserID
FROM CurrentUser CU;

SELECT * FROM CurrentUserView;



-------DECLARING CSEAUST129Server PACKAGE----------
CREATE OR REPLACE PACKAGE CSEAUST129Server AS
	
	PROCEDURE Feature_Normalization(
        Max1 IN OUT NUMBER, Max2 IN OUT NUMBER, Max3 IN OUT NUMBER, Max4 IN OUT NUMBER, Max5 IN OUT NUMBER, 
        Min1 IN OUT NUMBER, Min2 IN OUT NUMBER, Min3 IN OUT NUMBER, Min4 IN OUT NUMBER, Min5 IN OUT NUMBER,
        n_EstdIncome IN OUT NUMBER, n_HBalance IN OUT NUMBER, n_CScore IN OUT NUMBER, 
        n_RScore IN OUT NUMBER, n_CreditVal IN OUT NUMBER
    );
	
	PROCEDURE Logistic_Regression_Algorithm(
        SelectedID  IN OUT NUMBER, n_EstdIncome IN OUT NUMBER, n_HBalance   IN OUT NUMBER, 
        n_CScore    IN OUT NUMBER, n_RScore     IN OUT NUMBER, n_CreditVal  IN OUT NUMBER, 
        card_offer  IN OUT NUMBER, Prediction1  IN OUT NUMBER, Prediction2  IN OUT NUMBER, 
        b0 IN OUT NUMBER, b1 IN OUT NUMBER, b2 IN OUT NUMBER, b3 IN OUT NUMBER, b4 IN OUT NUMBER, b5 IN OUT NUMBER, 
        e IN OUT NUMBER, Error_Score IN OUT NUMBER, error IN OUT NUMBER, alpha IN OUT NUMBER
    );

    /*FUNCTION Card_Eligibility_Prediction(
        Test_EstdIncome IN OUT NUMBER, Test_HBalance IN OUT NUMBER, Test_CScore IN OUT NUMBER, 
        Test_RScore     IN OUT NUMBER, Test_CreditVal IN OUT NUMBER, Prediction2 IN OUT NUMBER, 
        b0 IN OUT NUMBER, b1 IN OUT NUMBER, b2 IN OUT NUMBER, b3 IN OUT NUMBER, b4 IN OUT NUMBER, b5 IN OUT NUMBER, 
        Max1 IN OUT NUMBER, Max2 IN OUT NUMBER, Max3 IN OUT NUMBER, Max4 IN OUT NUMBER, Max5 IN OUT NUMBER, 
        Min1 IN OUT NUMBER, Min2 IN OUT NUMBER, Min3 IN OUT NUMBER, Min4 IN OUT NUMBER, Min5 IN OUT NUMBER,
        TestingUserID IN NUMBER
    )
	RETURN NUMBER;*/
	
END CSEAUST129Server;
/


--------IMPLEMENTING THE BODY OF CSEAUST129Server PACKAGE-------- 
CREATE OR REPLACE PACKAGE BODY CSEAUST129Server AS

    -- Declaring the procedure for feature normalization --
	
	PROCEDURE Feature_Normalization(
        Max1 IN OUT NUMBER, Max2 IN OUT NUMBER, Max3 IN OUT NUMBER, Max4 IN OUT NUMBER, Max5 IN OUT NUMBER, 
        Min1 IN OUT NUMBER, Min2 IN OUT NUMBER, Min3 IN OUT NUMBER, Min4 IN OUT NUMBER, Min5 IN OUT NUMBER,
        n_EstdIncome IN OUT NUMBER, n_HBalance IN OUT NUMBER, n_CScore IN OUT NUMBER, 
        n_RScore IN OUT NUMBER, n_CreditVal IN OUT NUMBER
        )
	IS

    num1 number := 1;

    BEGIN

        SELECT MAX(EstdIncome)  INTO Max1 FROM CreditCardDataset;
        SELECT MAX(HBalance)    INTO Max2 FROM CreditCardDataset;
        SELECT MAX(CScore)      INTO Max3 FROM CreditCardDataset;
        SELECT MAX(RScore)      INTO Max4 FROM CreditCardDataset;
        SELECT MAX(CreditVal)   INTO Max5 FROM CreditCardDataset;

        SELECT MIN(EstdIncome)  INTO Min1 FROM CreditCardDataset;
        SELECT MIN(HBalance)    INTO Min2 FROM CreditCardDataset;
        SELECT MIN(CScore)      INTO Min3 FROM CreditCardDataset;
        SELECT MIN(RScore)      INTO Min4 FROM CreditCardDataset;
        SELECT MIN(CreditVal)   INTO Min5 FROM CreditCardDataset;


        FOR X IN (SELECT * FROM CreditCardDataset) LOOP
            n_EstdIncome    := (X.EstdIncome - Min1) / (Max1 - Min1);
            n_HBalance      := (X.HBalance - Min2) / (Max2 - Min2);
            n_CScore        := (X.CScore - Min3) / (Max3 - Min3);
            n_RScore        := (X.RScore - Min4) / (Max4 - Min4);
            n_CreditVal     := (X.CreditVal - Min5) / (Max5 - Min5);

            INSERT INTO FNCreditCardDataset VALUES(num1,n_EstdIncome,n_HBalance,n_CScore,n_RScore,n_CreditVal);
            num1 := num1 + 1;

        END LOOP;

        COMMIT;

	END Feature_Normalization;







    PROCEDURE Logistic_Regression_Algorithm(
        SelectedID  IN OUT NUMBER, n_EstdIncome IN OUT NUMBER, n_HBalance   IN OUT NUMBER, 
        n_CScore    IN OUT NUMBER, n_RScore     IN OUT NUMBER, n_CreditVal  IN OUT NUMBER, 
        card_offer  IN OUT NUMBER, Prediction1  IN OUT NUMBER, Prediction2  IN OUT NUMBER, 
        b0 IN OUT NUMBER, b1 IN OUT NUMBER, b2 IN OUT NUMBER, b3 IN OUT NUMBER, b4 IN OUT NUMBER, b5 IN OUT NUMBER, 
        e IN OUT NUMBER, Error_Score IN OUT NUMBER, error IN OUT NUMBER, alpha IN OUT NUMBER
        )
    IS


    BEGIN

        FOR X IN 1..2000 LOOP

            SelectedID := MOD(X,1000);            

            IF SelectedID = 0 THEN
                SelectedID := 1000;
            END IF;

            Select N_EstdIncome,N_HBalance,N_CScore,N_RScore,N_CreditVal
            Into n_EstdIncome,n_HBalance,n_CScore,n_RScore,n_CreditVal
            From FNCreditCardDataset Where ID = SelectedID;

            Select CardOffer Into card_offer From CreditCardDataset Where ID = SelectedID;

            Prediction1 := (-1) * (b0 + b1 * n_EstdIncome+ b2 * n_HBalance + b3 * n_CScore + b4 * n_RScore + b5 * n_CreditVal); 

            Prediction2 := (1 + POWER(e,Prediction1));

            Prediction2 := 1 / Prediction2;

            DBMS_OUTPUT.PUT_LINE('ID : ' || SelectedID || ' Prediction : 0' || Prediction2);
            --DBMS_OUTPUT.PUT_LINE('_______________________________________________________');

            error := card_offer - Prediction2;
            b0 := b0 + alpha * error * Prediction2 *(1-Prediction2);
            b1 := b1 + alpha * error * Prediction2 *(1-Prediction2) * n_EstdIncome;
            b2 := b2 + alpha * error * Prediction2 *(1-Prediction2) * n_HBalance;
            b3 := b3 + alpha * error * Prediction2 *(1-Prediction2) * n_CScore;
            b4 := b4 + alpha * error * Prediction2 *(1-Prediction2) * n_RScore;
            b5 := b5 + alpha * error * Prediction2 *(1-Prediction2) * n_CreditVal;

            IF Error_Score < error THEN
                Error_Score := error;
            END IF;

        END LOOP;



    END Logistic_Regression_Algorithm;








    /*FUNCTION Card_Eligibility_Prediction(
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
        From CustomerInfo Where Customer_ID = TestingUserID;

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

    END Card_Eligibility_Prediction;*/

	
END CSEAUST129Server;
/




DECLARE

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
    

    n_EstdIncome NUMBER;
    n_HBalance NUMBER;
    n_CScore NUMBER;
    n_RScore NUMBER;
    n_CreditVal NUMBER;

    Test_EstdIncome NUMBER;
    Test_HBalance NUMBER;
    Test_CScore NUMBER;
    Test_RScore NUMBER;
    Test_CreditVal NUMBER;

    card_offer NUMBER;

    b0 NUMBER := 0;
    b1 NUMBER := 0;
    b2 NUMBER := 0;
    b3 NUMBER := 0;
    b4 NUMBER := 0;
    b5 NUMBER := 0;

    Prediction1 NUMBER := 0;
    Prediction2 NUMBER := 0;

    SelectedID NUMBER := 0;

    e NUMBER := 2.7183;
    alpha NUMBER := 0.01; 
    error NUMBER;
    Error_Score NUMBER := 0;

    TestingUserID NUMBER := -1;
    
BEGIN

    DBMS_OUTPUT.PUT_LINE(' ------------ CSE-4126 (Distributed Database Systems Lab) Project ------------ ');

    
    /* Scalling Phase */
    CSEAUST129Server.Feature_Normalization(Max1, Max2, Max3, Max4, Max5, Min1, Min2, Min3, Min4, Min5, n_EstdIncome, 
    n_HBalance, n_CScore, n_RScore, n_CreditVal);

    DBMS_OUTPUT.PUT_LINE('---------------------------------');

    /* Training Phase */
    CSEAUST129Server.Logistic_Regression_Algorithm(SelectedID, n_EstdIncome, n_HBalance, n_CScore, n_RScore, n_CreditVal, 
    card_offer, Prediction1, Prediction2, b0, b1, b2, b3, b4, b5, e, Error_Score, error, alpha);
    
    
    DBMS_OUTPUT.PUT_LINE('_________________________');
    DBMS_OUTPUT.PUT_LINE('Values : ');
    DBMS_OUTPUT.PUT_LINE('B0: 0' || b0);
    DBMS_OUTPUT.PUT_LINE('B1: 0' || b1);
    DBMS_OUTPUT.PUT_LINE('B2: 0' || b2);
    DBMS_OUTPUT.PUT_LINE('B3: 0' || b3);
    DBMS_OUTPUT.PUT_LINE('B4: 0' || b4);
    DBMS_OUTPUT.PUT_LINE('B5: 0' || b5);  
    DBMS_OUTPUT.PUT_LINE('_________________________');

    INSERT INTO TestingDataset VALUES (1, Max1, Max2, Max3, Max4, Max5, Min1, Min2, Min3, Min4, Min5,b0, b1, b2, b3, b4, b5);
    COMMIT;

    /*Prediction2 := -1;

    Select UserID Into TestingUserID From CurrentUser Where SL = 1;

    Prediction2 := CSEAUST129Server.Card_Eligibility_Prediction(Test_EstdIncome, Test_HBalance, Test_CScore, Test_RScore, 
    Test_CreditVal, Prediction2, b0, b1, b2, b3, b4, b5, Max1, Max2, Max3, Max4, Max5, Min1, Min2, Min3, Min4, Min5,
    TestingUserID);
    
    DBMS_OUTPUT.PUT_LINE('_________________________');

    IF Prediction2 < 0 THEN
        DBMS_OUTPUT.PUT_LINE('No user data found!');
    ELSE 

	    UPDATE CustomerInfo SET Customer_CreditCardStatus = 1 WHERE Customer_ID = TestingUserID;

        Commit;

        DBMS_OUTPUT.PUT_LINE('The class predicted by the model: ' || TestingUserID);
    END IF;

    DBMS_OUTPUT.PUT_LINE('_________________________');*/

END;
/