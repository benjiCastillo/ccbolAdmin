CREATE PROCEDURE insertUser(in 
                            _email varchar(100) )
BEGIN
    IF ( SELECT EXISTS (SELECT 1 FROM user WHERE email = _email) ) THEN 
        SELECT 'EXISTS';
    ELSE
        SELECT 'DOES NOT EXISTS';
    END IF; 
END 

call insertUser('castilloeguezbenji@gmail.com')