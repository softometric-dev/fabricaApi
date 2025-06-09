-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 06, 2025 at 08:10 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fabrica_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addRolePermissions` (IN `p_userTypeId` INT, IN `p_roleId` INT, IN `p_permissionId` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
		INSERT INTO tbl_role_permissions(roleId,permissionId) VALUES(p_roleId,p_permissionId);
    END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addUserRoles` (IN `p_userProfileId` INT, IN `p_roleId` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
		INSERT INTO tbl_user_roles(userProfileId,roleId) VALUES(p_userProfileId,p_roleId);
	END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addVerifyEmail` (IN `p_email` VARCHAR(255), IN `p_verificationCode` VARCHAR(255))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    SET @lastId := 0;
  	START TRANSACTION;
    BEGIN	        
    	-- Application-level lock
    	SET @lock_variable := GET_LOCK('tbl_email_verification_lock', 60);
		IF @lock_variable = 1 THEN
    	BEGIN
    		-- Get the maximum existing auto-increment value
    		 SELECT MAX(emailVerificationId) INTO @lastId
                FROM tbl_email_verification
                FOR UPDATE;   
    		-- Increment the maximum value by 1
    		SET @lastId := COALESCE(@lastId, 0) + 1;
            INSERT INTO tbl_email_verification (
                    emailVerificationId, email, verificationCode
                )
                VALUES (
                    @lastId, TRIM(p_email), TRIM(p_verificationCode)
                );
        	-- Release the application-level lock
    		SET @lock_variable := RELEASE_LOCK('tbl_email_verification_lock');
		END;
    	ELSE
    	BEGIN
         	SET @error_code := "";
            SET @error_message := "";
         	-- Error occurred during lock acquisition, retrieve error details
        	GET DIAGNOSTICS CONDITION 1 @error_code = MYSQL_ERRNO, @error_message = MESSAGE_TEXT;
            SET @error_message := CONCAT("Could not aquire lock Error code ", @error_code, " Error message : ",  @error_message);          
        	-- Raise a custom error message with the error code and message
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
    	END;
    	END IF;
	END;
	
	COMMIT;
	SELECT emailVerificationId,email
    FROM tbl_email_verification d
    WHERE emailVerificationId = @lastId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createBrand` (IN `p_brandName` VARCHAR(255), IN `p_categoryId` INT, IN `p_image` VARCHAR(255))   BEGIN
    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Declare variables
    SET @lastId := 0;
    SET @lock_variable := 0;

    -- Start transaction
    START TRANSACTION;
    BEGIN
        -- Application-level lock to avoid race condition
        SET @lock_variable := GET_LOCK('tbl_brand_lock', 60);

        IF @lock_variable = 1 THEN
        BEGIN
            -- Generate new brand ID
            SELECT MAX(brandId) INTO @lastId
            FROM tbl_brand
            FOR UPDATE;

            SET @lastId := COALESCE(@lastId, 0) + 1;

            -- Insert brand
            INSERT INTO tbl_brand (
                brandId,
                brandName,
                categoryId,
                image,
                brandModifiedDateTime
            ) VALUES (
                @lastId,
                TRIM(p_brandName),
                p_categoryId,
                TRIM(p_image),
                CURRENT_TIMESTAMP
            );

            -- Release lock
            SET @lock_variable := RELEASE_LOCK('tbl_brand_lock');
        END;
        ELSE
        BEGIN
            SET @error_code := '';
            SET @error_message := '';

            GET DIAGNOSTICS CONDITION 1 @error_code = MYSQL_ERRNO, @error_message = MESSAGE_TEXT;
            SET @error_message := CONCAT('Could not acquire lock. Error code: ', @error_code, ' Message: ', @error_message);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
        END;
        END IF;
    END;

    COMMIT;

    -- Return inserted brand
    SELECT * FROM tbl_brand WHERE brandId = @lastId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createFileOrFolder` (IN `p_resouceName` VARCHAR(256), IN `p_resouceType` VARCHAR(10), IN `p_size` INT, IN `p_parentId` INT, IN `p_lastModifiedUserProfileId` VARCHAR(256), IN `p_statusId` INT, IN `p_extension` VARCHAR(10), IN `p_contentType` VARCHAR(50))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	SET @lastId := 0;
    START TRANSACTION;
    BEGIN
		SELECT btreeNode,resourceId INTO @parentBtreeNode,@parentId FROM tbl_resources where resourceId = p_parentId;
        IF FOUND_ROWS() = 1 THEN
        BEGIN
        	-- Application-level lock
			SET @lock_variable := GET_LOCK('tbl_resources_lock', 60);
			IF @lock_variable = 1 THEN
			BEGIN
				-- Get the maximum existing auto-increment value
				SELECT MAX(resourceId) INTO @lastId
				FROM tbl_resources
				FOR UPDATE;	        
				-- Increment the maximum value by 1
				SET @lastId := COALESCE(@lastId, 0) + 1;
				SET @newBtreeNode := CONCAT_WS(',', @parentBtreeNode, @lastId);
				INSERT INTO tbl_resources(resourceId, resourceName, resourceType, size, parentId, btreeNode, lastModifiedUserProfileId, statusId, extension, contentType) VALUES (@lastId, TRIM(p_resouceName),p_resouceType,p_size,p_parentId,@newBtreeNode,p_lastModifiedUserProfileId,p_statusId,p_extension,p_contentType);
				-- Release the application-level lock
				SET @lock_variable := RELEASE_LOCK('tbl_resources_lock');
			END;
			ELSE
			BEGIN
				SET @error_code := "";
				SET @error_message := "";
				-- Error occurred during lock acquisition, retrieve error details
				GET DIAGNOSTICS CONDITION 1 @error_code = MYSQL_ERRNO, @error_message = MESSAGE_TEXT;
				SET @error_message := CONCAT("Could not aquire lock Error code ", @error_code, " Error message : ",  @error_message);          
				-- Raise a custom error message with the error code and message
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
			END;
			END IF;
         END;
         ELSE
         BEGIN
         	DECLARE error_message VARCHAR(256);
         	SET error_message = CONCAT('ParentId ''', CAST(p_parentId AS CHAR), ''' does not exist or more than one parent found with same id');
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
         END;
         END IF;
    END;
	COMMIT;
	SELECT *,fn_getPath(btreeNode) as path,CONCAT(up.firstName," ",up.lastName) as lastModifiedUser from tbl_resources rs  LEFT JOIN tbl_user_profiles up ON up.userProfileId = rs.lastModifiedUserProfileId INNER JOIN tbl_status stat ON stat.statusId = rs.statusId where resourceId =  @lastId;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createNotification` (IN `p_userProfileId` INT, IN `p_message` TEXT, IN `p_status` INT, IN `p_type` VARCHAR(20), IN `p_navigationId` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    SET @lastId := 0;
  	START TRANSACTION;
    BEGIN	        
    	-- Application-level lock
    	SET @lock_variable := GET_LOCK('tbl_notifications_lock', 60);
		IF @lock_variable = 1 THEN
    	BEGIN
    		-- Get the maximum existing auto-increment value
    		 SELECT MAX(notificationId) INTO @lastId
                FROM tbl_notifications
                FOR UPDATE;   
    		-- Increment the maximum value by 1
    		SET @lastId := COALESCE(@lastId, 0) + 1;
            INSERT INTO tbl_notifications (
                    notificationId, userProfileId, message, status, notificationModifiedDateTime,type,navigationId
                )
                VALUES (
                    @lastId, p_userProfileId, TRIM(p_message), p_status,NOW(),p_type,p_navigationId
                   
                );
        	-- Release the application-level lock
    		SET @lock_variable := RELEASE_LOCK('tbl_notifications_lock');
		END;
    	ELSE
    	BEGIN
         	SET @error_code := "";
            SET @error_message := "";
         	-- Error occurred during lock acquisition, retrieve error details
        	GET DIAGNOSTICS CONDITION 1 @error_code = MYSQL_ERRNO, @error_message = MESSAGE_TEXT;
            SET @error_message := CONCAT("Could not aquire lock Error code ", @error_code, " Error message : ",  @error_message);          
        	-- Raise a custom error message with the error code and message
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
    	END;
    	END IF;
	END;
	COMMIT;
	SELECT n.*,up.*
    FROM tbl_notifications n
    LEFT JOIN tbl_user_profiles up ON up.userProfileId = n.userProfileId
    WHERE n.notificationId = @lastId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createPermission` (IN `p_permissionName` VARCHAR(50), IN `p_permissionDescription` VARCHAR(256))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    SET @lastId := 0;
  	START TRANSACTION;
    BEGIN
    	-- Application-level lock
   		SET @lock_variable := GET_LOCK('tbl_permissions_lock', 60);
		IF @lock_variable = 1 THEN
   		BEGIN
    		-- Get the maximum existing auto-increment value
    		SELECT MAX(permissionId) INTO @lastId
    		FROM tbl_permissions
    		FOR UPDATE;	        
    		-- Increment the maximum value by 1
    		SET @lastId := COALESCE(@lastId, 0) + 1;
        
			INSERT INTO tbl_permissions(permissionId,permissionName,permissionDescription) VALUES(@lastId,TRIM(p_permissionName),TRIM(p_permissionDescription));
        		
        	-- Release the application-level lock
    		SET @lock_variable := RELEASE_LOCK('tbl_permissions_lock');
		END;
    	ELSE
    	BEGIN
         	SET @error_code := "";
            SET @error_message := "";
         	-- Error occurred during lock acquisition, retrieve error details
        	GET DIAGNOSTICS CONDITION 1 @error_code = MYSQL_ERRNO, @error_message = MESSAGE_TEXT;
    	        SET @error_message := CONCAT("Could not aquire lock Error code ", @error_code, " Error message : ",  @error_message);          
        	-- Raise a custom error message with the error code and message
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
    	END;
    	END IF;
    END;
	COMMIT;
	SELECT * from tbl_permissions WHERE permissionId =  @lastId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createProduct` (IN `p_productName` VARCHAR(255), IN `p_size` VARCHAR(255), IN `p_categoryId` INT, IN `p_brandId` INT, IN `p_image` VARCHAR(255), IN `p_specification` TEXT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET @lastId := 0;

    START TRANSACTION;

    BEGIN
        -- Acquire application-level lock for tbl_product
        SET @lock_variable := GET_LOCK('tbl_product_lock', 60);

        IF @lock_variable = 1 THEN
        BEGIN
            -- Get the current max productId with FOR UPDATE to lock row
            SELECT MAX(productId) INTO @lastId FROM tbl_product FOR UPDATE;

            -- Increment the productId
            SET @lastId := COALESCE(@lastId, 0) + 1;

            -- Insert new product record
            INSERT INTO tbl_product(
                productId,
                productName,
                size,
                categoryId,
                brandId,
                image,
                specification,
                productModifiedDateTime
            ) VALUES (
                @lastId,
                TRIM(p_productName),
                TRIM(p_size),
                p_categoryId,
                p_brandId,
                TRIM(p_image),
                p_specification,
                NOW()
            );

            -- Release the lock
            SET @lock_variable := RELEASE_LOCK('tbl_product_lock');
        END;
        ELSE
        BEGIN
            DECLARE err_code INT DEFAULT 0;
            DECLARE err_msg VARCHAR(255) DEFAULT '';

            -- Get diagnostics
            GET DIAGNOSTICS CONDITION 1
                err_code = MYSQL_ERRNO,
                err_msg = MESSAGE_TEXT;

            SET err_msg := CONCAT('Could not acquire lock. Error code ', err_code, ', message: ', err_msg);

            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = err_msg;
        END;
        END IF;
    END;

    COMMIT;

    -- Return the newly inserted product
    SELECT * FROM tbl_product WHERE productId = @lastId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createRole` (IN `p_userTypeId` INT, IN `p_roleName` VARCHAR(50), IN `p_roleDescription` VARCHAR(256))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	SET @lastId := 0;
    START TRANSACTION;
    BEGIN
		-- Application-level lock
    	SET @lock_variable := GET_LOCK('tbl_roles_lock', 60);
		IF @lock_variable = 1 THEN
   		BEGIN
    		-- Get the maximum existing auto-increment value
    		SELECT MAX(roleId) INTO @lastId
    		FROM tbl_roles
    		FOR UPDATE;	        
    		-- Increment the maximum value by 1
    		SET @lastId := COALESCE(@lastId, 0) + 1;
        	INSERT INTO tbl_roles(roleId,roleName,roleDescription) VALUES(@lastId,TRIM(p_roleName),TRIM(p_roleDescription));
			INSERT INTO tbl_role_groups(userTypeId,roleId) VALUES(p_userTypeId, @lastId);
            -- Release the application-level lock
    		SET @lock_variable := RELEASE_LOCK('tbl_roles_lock');
		END;
   	 	ELSE
    	BEGIN
         	SET @error_code := "";
            SET @error_message := "";
         	-- Error occurred during lock acquisition, retrieve error details
        	GET DIAGNOSTICS CONDITION 1 @error_code = MYSQL_ERRNO, @error_message = MESSAGE_TEXT;
            SET @error_message := CONCAT("Could not aquire lock Error code ", @error_code, " Error message : ",  @error_message);          
        	-- Raise a custom error message with the error code and message
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
    	END;
    	END IF;
    END;
	COMMIT;
	SELECT * from tbl_roles WHERE roleId =  @lastId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createUserAuditLog` (IN `p_userProfileId` INT, IN `p_action` VARCHAR(50), IN `p_deviceId` VARCHAR(50), IN `p_comments` VARCHAR(256))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    SET @lastId := 0;
  	BEGIN
    	-- Application-level lock
   		SET @lock_variable := GET_LOCK('tbl_user_login_audit_lock', 60);
		IF @lock_variable = 1 THEN
   		BEGIN
    		-- Get the maximum existing auto-increment value
    		SELECT MAX(userLoginAuditId) INTO @lastId
    		FROM tbl_user_login_audit
    		FOR UPDATE;	        
    		-- Increment the maximum value by 1
    		SET @lastId := COALESCE(@lastId, 0) + 1;
        
			INSERT INTO tbl_user_login_audit(userLoginAuditId,userProfileId,action,deviceId,comments) VALUES(@lastId,p_userProfileId,TRIM(p_action),TRIM(p_deviceId),TRIM(p_comments));
        		
        	-- Release the application-level lock
    		SET @lock_variable := RELEASE_LOCK('tbl_user_login_audit_lock');
		END;
    	ELSE
    	BEGIN
         	SET @error_code := "";
            SET @error_message := "";
         	-- Error occurred during lock acquisition, retrieve error details
        	GET DIAGNOSTICS CONDITION 1 @error_code = MYSQL_ERRNO, @error_message = MESSAGE_TEXT;
    	        SET @error_message := CONCAT("Could not aquire lock Error code ", @error_code, " Error message : ",  @error_message);          
        	-- Raise a custom error message with the error code and message
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
    	END;
    	END IF;
    END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createUserProfile` (IN `p_firstName` VARCHAR(50), IN `p_middleName` VARCHAR(50), IN `p_lastName` VARCHAR(50), IN `p_dateOfBirth` DATETIME, IN `p_addressLine1` VARCHAR(300), IN `p_addressLine2` VARCHAR(300), IN `p_stateId` INT, IN `p_countryId` INT, IN `p_zipOrPostCode` VARCHAR(20), IN `p_email` VARCHAR(50), IN `p_phone` VARCHAR(20), IN `p_mobile` VARCHAR(20), IN `p_password` VARCHAR(256), IN `p_statusId` INT, IN `p_userTypeId` INT, IN `p_roleId` INT, IN `p_ipAddress` VARCHAR(255))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    SET @lastId := 0;
  	START TRANSACTION;
    BEGIN
    	-- Application-level lock
    	SET @lock_variable := GET_LOCK('tbl_user_profiles_lock', 60);
		IF @lock_variable = 1 THEN
    	BEGIN
    		-- Get the maximum existing auto-increment value
    		SELECT MAX(userProfileId) INTO @lastId
    		FROM tbl_user_profiles
    		FOR UPDATE;	        
    		-- Increment the maximum value by 1
    		SET @lastId := COALESCE(@lastId, 0) + 1;
            
			INSERT INTO tbl_user_profiles(userProfileId,firstName,middleName,lastName,dateOfBirth,addressLine1,addressLine2,stateId,countryId,zipOrPostCode,email,phone,mobile,password,statusId,userTypeId,ipAddress) VALUES(@lastId,TRIM(p_firstName),TRIM(p_middleName),TRIM(p_lastName),p_dateOfBirth,TRIM(p_addressLine1),TRIM(p_addressLine2),p_stateId,p_countryId,TRIM(p_zipOrPostCode),TRIM(p_email),TRIM(p_phone),TRIM(p_mobile),TRIM(p_password),p_statusId,p_userTypeId,TRIM(p_ipAddress));
            
            INSERT INTO tbl_user_roles(userProfileId,roleId) VALUES(@lastId,p_roleId);
            -- Release the application-level lock
    		SET @lock_variable := RELEASE_LOCK('tbl_user_profiles_lock');
		END;
    	ELSE
    	BEGIN
         	SET @error_code := "";
            SET @error_message := "";
         	-- Error occurred during lock acquisition, retrieve error details
        	GET DIAGNOSTICS CONDITION 1 @error_code = MYSQL_ERRNO, @error_message = MESSAGE_TEXT;
            SET @error_message := CONCAT("Could not aquire lock Error code ", @error_code, " Error message : ",  @error_message);          
        	-- Raise a custom error message with the error code and message
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
    	END;
    	END IF;            
	END;
	COMMIT;
	SELECT * from tbl_user_profiles up 
    INNER JOIN tbl_user_types ut ON ut.userTypeId = up.userTypeId
    INNER JOIN tbl_status us ON us.statusId = up.statusId
    LEFT JOIN tbl_countries ct ON ct.countryId=up.countryId 
    LEFT JOIN tbl_states st ON ct.countryId=st.countryId AND st.stateId=up.stateId 
    WHERE userProfileId =  @lastId; 
    
    SELECT rl.* FROM tbl_roles rl 
    INNER JOIN tbl_user_roles ur ON ur.roleId = rl.roleId
    WHERE ur.userProfileId=@lastId; 
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteBrandByBrandId` (IN `p_brandId` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    BEGIN
        BEGIN
            DELETE FROM tbl_brand WHERE brandId = p_brandId;
            SELECT ROW_COUNT() AS noOfRowsDeleted;
        END;
    END;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteFileOrFolderById` (IN `p_resourceId` INT, IN `p_resourceType` VARCHAR(10))   BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	CREATE TEMPORARY TABLE temp_rows_to_delete
        SELECT *, fn_getPath(btreeNode) AS path
        FROM tbl_resources
        WHERE resourceId = p_resourceId AND resourceType = p_resourceType;
    
        SELECT COUNT(*) INTO @row_count FROM temp_rows_to_delete;
        IF @row_count = 1 THEN 
    	
        BEGIN
    		DELETE FROM tbl_resources WHERE (resourceId = p_resourceId AND resourceType = p_resourceType) OR btreeNode LIKE CONCAT('%,',p_resourceId,',%');
            SELECT * FROM temp_rows_to_delete;
            DROP TEMPORARY TABLE temp_rows_to_delete;
        END;
        ELSE
        BEGIN
        	DECLARE error_message VARCHAR(256);
         	SET error_message = CONCAT(p_resourceType, ' recourceId ''', CAST(p_resourceId AS CHAR), ''' does not exist or more than one row found with same id');
        	DROP TEMPORARY TABLE temp_rows_to_delete;
         	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END;
        END IF;
    END;    
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deletePermissionByPermissionId` (IN `p_permissionId` INT)   BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
   		DELETE FROM tbl_permissions WHERE permissionId = p_permissionId;
        SELECT ROW_COUNT() AS noOfRowsDeleted;
    END;    
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deletePermissionByPermissionName` (IN `p_permissionName` VARCHAR(50))   BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	DELETE FROM tbl_permissions WHERE LOWER(permissionName) = TRIM(LOWER(p_permissionName));
        SELECT ROW_COUNT() AS noOfRowsDeleted;
    END;    
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteProductByProductId` (IN `p_productId` INT)   BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    BEGIN
        BEGIN
            DELETE FROM tbl_product WHERE productId = p_productId;
            SELECT ROW_COUNT() AS noOfRowsDeleted;
        END;
    END;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteRoleByRoleId` (IN `p_roleId` INT)   BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	DELETE FROM tbl_roles WHERE roleId = p_roleId;
        SELECT ROW_COUNT() AS noOfRowsDeleted;
    END;    
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteRoleByRoleName` (IN `p_roleName` VARCHAR(50))   BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	DELETE FROM tbl_roles WHERE LOWER(roleName) = TRIM(LOWER(p_roleName));
        SELECT ROW_COUNT() AS noOfRowsDeleted;
    END;    
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteRolePermissionByRoleId` (IN `p_roleId` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	DELETE FROM tbl_role_permissions WHERE roleId = p_roleId;
    END;    
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteUserProfileByEmail` (IN `p_email` VARCHAR(50))   BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	DELETE FROM tbl_user_profiles WHERE LOWER(email) = TRIM(LOWER(p_email));
        SELECT ROW_COUNT() AS noOfRowsDeleted;
    END;    
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteUserProfileByUserProfileId` (IN `p_userProfileId` INT)   BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	BEGIN
        	DELETE FROM tbl_user_profiles WHERE userProfileId = p_userProfileId;
            SELECT ROW_COUNT() AS noOfRowsDeleted;
        END;        
    END;    
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteVerifiedEmailByEmail` (IN `p_email` VARCHAR(255))   BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	DELETE FROM tbl_email_verification WHERE LOWER(email) = TRIM(LOWER(p_email));
        SELECT ROW_COUNT() AS noOfRowsDeleted;
    END;    
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllCategory` (IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS * FROM tbl_category ","LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
		PREPARE stmt FROM @sql;
		EXECUTE stmt;   
        DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
    END;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllCountries` (IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS * FROM tbl_countries ","LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
		PREPARE stmt FROM @sql;
		EXECUTE stmt;   
        DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
    END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllStatesByCountryId` (IN `p_countryId` INT, IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS * FROM tbl_states WHERE countryId = ",p_countryId," LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
		PREPARE stmt FROM @sql;
		EXECUTE stmt;   
        DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
    END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllStatus` (IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS * FROM tbl_status ","LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
		PREPARE stmt FROM @sql;
		EXECUTE stmt;   
        DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
    END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllUserRoles` (IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS * FROM tbl_roles rl INNER JOIN tbl_role_groups rlg ON rlg.roleId = rl.roleId INNER JOIN tbl_user_types ut ON ut.userTypeId = rlg.UserTypeId ","LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
		PREPARE stmt FROM @sql;
		EXECUTE stmt;   
        DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
    END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllUserTypes` (IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS * FROM tbl_user_types ","LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
		PREPARE stmt FROM @sql;
		EXECUTE stmt;   
        DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
    END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getBrandByBrandId` (IN `p_brandId` INT)   BEGIN
    -- Error handler for SQL exceptions
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

     BEGIN
        -- Get brand info along with category name
        SELECT b.*, c.categoryName
        FROM tbl_brand b
        LEFT JOIN tbl_category c ON b.categoryId = c.categoryId
        WHERE b.brandId = p_brandId;
    END;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getFileOrFolderById` (IN `p_resourceId` INT, IN `p_resourceType` VARCHAR(10), IN `p_include_child` BOOLEAN, IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    
    	SELECT rs.*,fn_getPath(rs.btreeNode) as path,CONCAT(up.firstName," ",up.lastName) as lastModifiedUser
        FROM tbl_resources rs LEFT JOIN tbl_user_profiles up ON up.userProfileId = rs.lastModifiedUserProfileId
        WHERE rs.resourceId = p_resourceId AND rs.resourceType = p_resourceType ORDER BY rs.parentId,rs.resourceId;
            
    	IF p_include_child = true THEN
        BEGIN
        	SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS *,fn_getPath(btreeNode) as path,CONCAT(up.firstName,' ',up.lastName) as lastModifiedUser
         	FROM tbl_resources rs LEFT JOIN tbl_user_profiles up ON up.userProfileId = rs.lastModifiedUserProfileId
            WHERE rs.parentId = ",p_resourceId," ORDER BY rs.resourceType DESC,rs.resourceId LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
            PREPARE stmt FROM @sql;
			EXECUTE stmt;   
        	DEALLOCATE PREPARE stmt;
        	SET @totalRecords =  FOUND_ROWS();
        	SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;        
        END;
        END IF;
    END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getNotificationByNotificationId` (IN `p_notificationId` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN

    SELECT n.*
    FROM tbl_notifications n
    WHERE n.notificationId = p_notificationId;

     SELECT 
        up.*
    FROM 
        tbl_user_profiles up
    WHERE 
        up.userProfileId = (SELECT userProfileId FROM tbl_notifications WHERE notificationId = p_notificationId);
        
    END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getPermissionByPermissionId` (IN `p_permissionId` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN		
		SELECT * from tbl_permissions WHERE permissionId = p_permissionId;
		COMMIT;
    END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getPermissionByPermissionName` (IN `p_permissionName` VARCHAR(50))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN		
		SELECT * from tbl_permissions WHERE LOWER(permissionName) = TRIM(LOWER(p_permissionName));
		COMMIT;
    END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getProductById` (IN `p_productId` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    BEGIN
        SELECT 
            p.*, 
            c.categoryName, 
            b.brandName 
        FROM tbl_product p
        LEFT JOIN tbl_category c ON c.categoryId = p.categoryId
        LEFT JOIN tbl_brand b ON b.brandId = p.brandId
        WHERE p.productId = p_productId;
    END;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getResourceStatitics` (IN `p_searchBy` VARCHAR(50), IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @groupClause = ' GROUP BY ';
        SET @selColumn = CONCAT("'",COALESCE(p_searchBy, ''),"'"," as searchBy,");
        SET @joinClause = '';
        SET @orderBy = ' ORDER BY ';
        SET @searchBy = TRIM(LOWER(COALESCE(p_searchBy, '')));
        SET @whereClause = '';
		IF @searchBy = 'resourcetype' THEN
        	SET @selColumn = CONCAT(@selColumn, "rs.resourceType as value,count(rs.resourceId) as count");
  			SET @groupClause = CONCAT(@groupClause, "rs.resourceType");
            SET @orderBy = CONCAT(@orderBy, "rs.resourceType");       
        ELSE
        	SET @selColumn = CONCAT(@selColumn, "count(rs.resourceId) as count");
            SET @groupClause = '';
            SET @orderBy = CONCAT(@orderBy, "rs.resourceId");
        END IF;	
        
        SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS ",@selColumn," FROM tbl_resources rs ",@joinClause,@whereClause,@groupClause,@orderBy," LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
        PREPARE stmt FROM @sql;
		EXECUTE stmt;   
       	DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
       
    END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getRoleByRoleId` (IN `p_roleId` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN		
		SELECT * from tbl_roles rl 
        INNER JOIN tbl_role_groups rlg ON rlg.roleId = rl.roleId 
        INNER JOIN tbl_user_types ut ON ut.userTypeId = rlg.UserTypeId WHERE rl.roleId = p_roleId;
		COMMIT;
    END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getRoleByRoleName` (IN `p_roleName` VARCHAR(50))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN		
		SELECT * from tbl_roles rl 
        INNER JOIN tbl_role_groups rlg ON rlg.roleId = rl.roleId 
        INNER JOIN tbl_user_types ut ON ut.userTypeId = rlg.UserTypeId 
        WHERE LOWER(rl.roleName) = TRIM(LOWER(p_roleName));
		COMMIT;
    END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getRolePermissionsByRoleId` (IN `p_roleId` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
		SELECT * from tbl_role_permissions rp 
        INNER JOIN tbl_roles rl ON rl.roleId = rp.roleId
        INNER JOIN tbl_permissions pr ON pr.permissionId = rp.permissionId 
        WHERE rp.roleId = p_roleId;
	END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getUserPermissionsByUserProfileId` (IN `p_userProfileId` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
		SELECT DISTINCT pr.* FROM tbl_user_roles ur 
        INNER JOIN tbl_role_permissions rp ON rp.roleId = ur.roleId
        INNER JOIN tbl_permissions pr ON pr.permissionId = rp.permissionId
        INNER JOIN tbl_user_profiles up ON up.userProfileId = ur.userProfileId
        WHERE ur.userProfileId = p_userProfileId AND up.statusId <> 3;
	END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getUserProfileByEmail` (IN `p_email` VARCHAR(50))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN		
	SELECT * from tbl_user_profiles up INNER JOIN tbl_status us ON us.statusId = up.statusId INNER JOIN tbl_user_types ut ON ut.userTypeId=up.userTypeId LEFT JOIN tbl_countries ct ON ct.countryId=up.countryId LEFT JOIN tbl_states st ON ct.countryId=st.countryId AND st.stateId=up.stateId WHERE LOWER(email) = TRIM(LOWER(p_email));
	COMMIT;
    END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getUserProfileByUserProfileId` (IN `p_userProfileId` INT)   BEGIN
	SELECT * from tbl_user_profiles up INNER JOIN tbl_status us ON us.statusId = up.statusId INNER JOIN tbl_user_types ut ON ut.userTypeId=up.userTypeId LEFT JOIN tbl_countries ct ON ct.countryId=up.countryId LEFT JOIN tbl_states st ON ct.countryId=st.countryId AND st.stateId=up.stateId WHERE userProfileId =  p_userProfileId;
    
    SELECT rl.* FROM tbl_roles rl 
    INNER JOIN tbl_user_roles ur ON ur.roleId = rl.roleId
    WHERE ur.userProfileId=p_userProfileId;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getUserRolesByUserProfileId` (IN `p_userProfileId` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
		SELECT * from tbl_user_roles ur 
        INNER JOIN tbl_user_profiles up ON up.userProfileId = ur.userProfileId
        INNER JOIN tbl_roles rl ON rl.roleId = ur.roleId
        WHERE ur.userProfileId = p_userProfileId;
	END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getUserStatitics` (IN `p_searchBy` VARCHAR(50), IN `p_filter` VARCHAR(256), IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @wherClause = '';
        SET @groupClause = ' GROUP BY ';
        SET @selColumn = CONCAT("'",COALESCE(p_searchBy, ''),"'"," as searchBy,");
        SET @joinClause = '';
        SET @orderBy = ' ORDER BY ';
        SET @searchBy = TRIM(LOWER(COALESCE(p_searchBy, '')));
		IF @searchBy = 'status' THEN
        	SET @selColumn = CONCAT(@selColumn, "stat.status as value,count(stat.statusId) as count");
  			SET @joinClause = CONCAT(@joinClause, "LEFT JOIN tbl_status stat ON stat.statusId = usrprf.statusId");
            SET @groupClause = CONCAT(@groupClause, "usrprf.statusId");
            SET @orderBy = CONCAT(@orderBy, "usrprf.statusId");
            IF COALESCE(p_filter, '') != '' THEN
            	SET @joinClause =  CONCAT(@joinClause, " INNER JOIN tbl_franchisee_users frausr ON frausr.userProfileId = usrprf.userProfileId");
                SET @wherClause =  CONCAT(@wherClause, " WHERE frausr.franchiseeId =",SUBSTRING_INDEX(SUBSTRING_INDEX(p_filter, ':', 2), ':', -1));
            END IF;
        ELSEIF @searchBy = 'state' THEN
        	SET @selColumn = CONCAT(@selColumn, "state.stateName as value,count(state.stateId) as count");
  			SET @joinClause = CONCAT(@joinClause, "LEFT JOIN tbl_countries ctry ON ctry.countryId = usrprf.countryId LEFT JOIN tbl_states state ON state.stateId = usrprf.stateId");
            SET @groupClause = CONCAT(@groupClause, "usrprf.stateId,usrprf.countryId");
            SET @orderBy = CONCAT(@orderBy, "usrprf.stateId,usrprf.countryId");
        ELSEIF  @searchBy = 'country' THEN
  			SET @selColumn = CONCAT(@selColumn, "ctry.countryName as value,count(ctry.countryId) as count");
  			SET @joinClause = CONCAT(@joinClause, "LEFT JOIN tbl_countries ctry ON ctry.countryId = usrprf.countryId");
            SET @groupClause = CONCAT(@groupClause, "usrprf.countryId");
            SET @orderBy = CONCAT(@orderBy, "usrprf.countryId");
        ELSEIF @searchBy = 'usertype' THEN
        	SET @selColumn = CONCAT(@selColumn, "usrtyp.userType as value,count(usrtyp.userTypeId) as count");
  			SET @joinClause = CONCAT(@joinClause, "LEFT JOIN tbl_user_types usrtyp ON usrtyp.userTypeId = usrprf.userTypeId");
            SET @groupClause = CONCAT(@groupClause, "usrprf.userTypeId");
            SET @orderBy = CONCAT(@orderBy, "usrprf.userTypeId");
        ELSEIF @searchBy = 'role' THEN
        	SET @selColumn = CONCAT(@selColumn, "rl.roleName as value,count(rl.roleId) as count");
  			SET @joinClause = CONCAT(@joinClause, "LEFT JOIN tbl_user_roles url ON url.userProfileId=usrprf.userProfileId INNER JOIN tbl_roles rl ON rl.roleId = url.roleId");
            SET @groupClause = CONCAT(@groupClause, "rl.roleId");
            SET @orderBy = CONCAT(@orderBy, "rl.roleId");
            IF COALESCE(p_filter, '') != '' THEN
            	SET @joinClause =  CONCAT(@joinClause, " INNER JOIN tbl_franchisee_users frausr ON frausr.userProfileId = usrprf.userProfileId");
                SET @wherClause =  CONCAT(@wherClause, " WHERE frausr.franchiseeId =",SUBSTRING_INDEX(SUBSTRING_INDEX(p_filter, ':', 2), ':', -1));
            END IF;
        ELSE
        	SET @selColumn = CONCAT(@selColumn, "count(usrprf.userProfileId) as count");
            SET @groupClause = '';
            SET @orderBy = CONCAT(@orderBy, "usrprf.userProfileId");
            
            IF COALESCE(p_filter, '') != '' THEN
            	SET @joinClause =  CONCAT(@joinClause, " INNER JOIN tbl_franchisee_users frausr ON frausr.userProfileId = usrprf.userProfileId");
                SET @wherClause =  CONCAT(@wherClause, " WHERE frausr.franchiseeId =",SUBSTRING_INDEX(SUBSTRING_INDEX(p_filter, ':', 2), ':', -1));
            END IF;
            
        END IF;	
     
     	SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS ",@selColumn," FROM tbl_user_profiles usrprf ",@joinClause,@wherClause,@groupClause,@orderBy," LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
        PREPARE stmt FROM @sql;
		EXECUTE stmt;   
       	DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
       
    END;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getVerifyEmailByEmailAndCode` (IN `p_email` VARCHAR(255), IN `p_verificationCode` VARCHAR(255))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN		
	SELECT * from tbl_email_verification WHERE LOWER(email) = TRIM(LOWER(p_email)) AND verificationCode = p_verificationCode;
	COMMIT;
    END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_removeUserRoleByUserProfileId` (IN `p_userProfileId` INT, IN `p_roleId` INT)   BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN    	
        DELETE FROM tbl_user_roles WHERE userProfileId = p_userProfileId AND roleId = p_roleId;
        SELECT FOUND_ROWS() AS noOfRowsDeleted;
    END;    
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_renameFileOrFolderById` (IN `p_resourceId` INT, IN `p_newResourceName` VARCHAR(256), IN `p_newExtension` VARCHAR(10), IN `p_lastModifiedUserProfileId` INT)   BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN	        
    	UPDATE tbl_resources SET resourceName = p_newResourceName, extension = p_newExtension, lastModifiedDateTime = NOW(),  lastModifiedUserProfileId = p_lastModifiedUserProfileId WHERE resourceId = p_resourceId;
    END;    
	COMMIT;
	SELECT rs.*,fn_getPath(rs.btreeNode) AS path,CONCAT(up.firstName,' ',up.lastName) as lastModifiedUser FROM tbl_resources rs LEFT JOIN tbl_user_profiles up ON up.userProfileId = rs.lastModifiedUserProfileId WHERE rs.resourceId =  p_resourceId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_searchBrand` (IN `p_brandName` VARCHAR(255), IN `p_categoryId` INT, IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    BEGIN
        SET @condition = '1=1 ';  -- base condition always true
        SET @join = '';

        -- Dynamic conditions

        IF COALESCE(p_brandName, '') != '' THEN
            SET @condition = CONCAT(@condition, " AND b.brandName LIKE CONCAT('%', ", QUOTE(p_brandName), ", '%')");
        END IF;

        IF p_categoryId IS NOT NULL THEN
            SET @condition = CONCAT(@condition, " AND b.categoryId = ", p_categoryId);
        END IF;

      
        -- Calculate offset for pagination
        SET @offset = (p_currentPage - 1) * p_pageSize;

        -- Final SQL query
        SET @sql = CONCAT(
            "SELECT SQL_CALC_FOUND_ROWS b.* ",
            "FROM tbl_brand b ",
            "WHERE ", @condition, " ",
            "ORDER BY b.brandId ",
            "LIMIT ", @offset, ", ", p_pageSize
        );

        -- Prepare, execute and deallocate
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Get total rows without LIMIT for pagination
        SET @totalRecords = FOUND_ROWS();

        -- Return pagination info
        SELECT p_currentPage AS CurrentPage,
               p_pageSize AS PageSize,
               @totalRecords AS TotalRecords,
               CEIL(@totalRecords / p_pageSize) AS TotalPages;

    END;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_searchFileOrFolder` (IN `p_resourceName` VARCHAR(256), IN `p_resourceType` VARCHAR(10), IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @condition = '';
        SET @join = "";
		IF COALESCE(p_resourceName, '') != '' THEN
  			SET @condition = CONCAT(@condition, "rs.resourceName LIKE '%", p_resourceName, "%' AND ");
		END IF;
		IF COALESCE(p_resourceType, '') != '' THEN
  			SET @condition = CONCAT(@condition, "rs.resourceType = '", p_resourceType, "' AND ");
		END IF;
        SET @condition = TRIM(TRAILING 'AND ' FROM @condition);      
        
        SET @sql = '';
        IF @condition = "" THEN
        	SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS *,fn_getPath(btreeNode) as path, CONCAT(up.firstName,' ', up.lastName) as lastModifiedUser FROM tbl_resources rs LEFT JOIN tbl_user_profiles up ON up.userProfileId = rs.lastModifiedUserProfileId WHERE rs.resourceId <> 1 ORDER BY rs.lastModifiedDateTime DESC LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
        ELSE
        	SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS *,fn_getPath(btreeNode) as path FROM tbl_resources rs",@join," WHERE ", @condition, "ORDER BY rs.resourceType, rs.resourceName LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
        END IF;
        PREPARE stmt FROM @sql;
		EXECUTE stmt;   
        DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;       
    END; 
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_searchNotifications` (IN `p_userProfileId` INT, IN `p_status` INT, IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    BEGIN
        -- Declare variables
        SET @condition = '';
        SET @join = '';

        -- Add dynamic conditions
        IF COALESCE(p_userProfileId, '') != '' AND p_userProfileId > 0 THEN
            SET @condition = CONCAT(@condition, "n.userProfileId = ", p_userProfileId, " AND ");
        END IF;

        IF COALESCE(p_status, '') != '' THEN
            SET @condition = CONCAT(@condition, "n.status = ", p_status, " AND ");
        END IF;

        -- Add dynamic joins if needed
        -- Example:
        -- IF some_condition THEN
        --     SET @join = CONCAT(@join, "INNER JOIN some_table ON condition ");
        -- END IF;

        -- Trim trailing AND from conditions
        SET @condition = TRIM(TRAILING 'AND ' FROM @condition);

        -- Construct the final SQL query
        SET @sql = CONCAT(
            "SELECT SQL_CALC_FOUND_ROWS n.*, ",
            "up.firstName, up.middleName, up.lastName, up.addressLine1, up.addressLine2, ",
            "up.zipOrPostCode, up.email, up.phone, up.mobile, up.userTypeId, up.statusId, ",
            "up.stateId, up.countryId ",
            "FROM tbl_notifications n ",
            "INNER JOIN tbl_user_profiles up ON n.userProfileId = up.userProfileId ",
            @join, -- Add dynamic joins if any
            IF(@condition != '', CONCAT("WHERE ", @condition), ''), " ",
            "ORDER BY n.notificationId DESC ",
            "LIMIT ", (p_currentPage * p_pageSize) - p_pageSize, ", ", p_pageSize
        );

        -- Prepare, execute, and clean up the dynamic SQL statement
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Fetch total records for pagination
        SET @totalRecords = FOUND_ROWS();

        -- Return pagination details
        SELECT 
            p_currentPage AS CurrentPage, 
            p_pageSize AS PageSize, 
            @totalRecords AS TotalRecords, 
            CEIL(@totalRecords / p_pageSize) AS TotalPages;
    END;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_searchPermission` (IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	
        SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS perm.* FROM tbl_permissions perm LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
        PREPARE stmt FROM @sql;
		EXECUTE stmt;   
        DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
       
    END; 
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_searchProduct` (IN `p_productName` VARCHAR(255), IN `p_size` VARCHAR(255), IN `p_categoryId` INT, IN `p_brandId` INT, IN `p_specification` TEXT, IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    BEGIN
        SET @condition = '1=1';

        -- Dynamic filters
        IF COALESCE(p_productName, '') != '' THEN
            SET @condition = CONCAT(@condition, " AND p.productName LIKE '%", p_productName, "%'");
        END IF;

        IF COALESCE(p_size, '') != '' THEN
            SET @condition = CONCAT(@condition, " AND p.size LIKE '%", p_size, "%'");
        END IF;

        IF COALESCE(p_categoryId, '') != '' THEN
            SET @condition = CONCAT(@condition, " AND p.categoryId = ", p_categoryId);
        END IF;

        IF COALESCE(p_brandId, '') != '' THEN
            SET @condition = CONCAT(@condition, " AND p.brandId = ", p_brandId);
        END IF;

        IF COALESCE(p_specification, '') != '' THEN
            SET @condition = CONCAT(@condition, " AND p.specification LIKE '%", p_specification, "%'");
        END IF;

        -- Final SQL query
        SET @sql = CONCAT(
            "SELECT SQL_CALC_FOUND_ROWS p.* ",
            "FROM tbl_product p ",
            "WHERE ", @condition, " ",
            "ORDER BY p.productId DESC ",
            "LIMIT ", (p_currentPage * p_pageSize) - p_pageSize, ",", p_pageSize
        );

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @totalRecords = FOUND_ROWS();

        SELECT 
            p_currentPage AS CurrentPage,
            p_pageSize AS PageSize,
            @totalRecords AS TotalRecords,
            CEIL(@totalRecords / p_pageSize) AS TotalPages;

    END;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_searchRole` (IN `p_userTypeId` VARCHAR(11), IN `p_userType` VARCHAR(15), IN `p_currentPage` VARCHAR(11), IN `p_pageSize` VARCHAR(11))  NO SQL BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @condition = '';
        SET @join = "";
		IF COALESCE(p_userTypeId, '') != '' THEN
  			SET @condition = CONCAT(@condition, "rg.userTypeId = '", p_userTypeId, "' AND ");
		END IF;
		IF COALESCE(p_userType, '') != '' THEN
  			SET @condition = CONCAT(@condition, "ut.userType = '", p_userType, "' AND ");
		END IF;        
       
        SET @condition = TRIM(TRAILING 'AND ' FROM @condition);         
        SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS DISTINCT rl.* FROM tbl_role_groups rg INNER JOIN tbl_user_types ut ON ut.userTypeId = rg.userTypeId INNER JOIN tbl_roles rl ON rg.roleId = rl.roleId ",@join," WHERE ", @condition, "LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
        PREPARE stmt FROM @sql;
		EXECUTE stmt;   
        DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
       
    END; 
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_searchUser` (IN `p_userTypeId` VARCHAR(11), IN `p_countryId` VARCHAR(11), IN `p_stateId` VARCHAR(11), IN `p_franchiseeId` VARCHAR(11), IN `p_roleId` VARCHAR(11), IN `p_firstName` VARCHAR(50), IN `p_middleName` VARCHAR(50), IN `p_lastName` VARCHAR(50), IN `p_email` VARCHAR(50), IN `p_statusId` VARCHAR(11), IN `p_currentPage` VARCHAR(11), IN `p_pageSize` VARCHAR(11), IN `p_dealerId` VARCHAR(11), IN `p_salesExecutiveId` VARCHAR(11), IN `p_fullName` VARCHAR(255))   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    BEGIN
        SET @condition = '';
        SET @join = '';

        -- Adding conditions dynamically
        IF COALESCE(p_userTypeId, '') != '' THEN
            SET @condition = CONCAT(@condition, "up.userTypeId = '", p_userTypeId, "' AND ");
        END IF;

        IF COALESCE(p_countryId, '') != '' THEN
            SET @condition = CONCAT(@condition, "up.countryId = '", p_countryId, "' AND ");
        END IF;

        IF COALESCE(p_stateId, '') != '' THEN
            SET @condition = CONCAT(@condition, "up.stateId = '", p_stateId, "' AND ");
        END IF;

        IF COALESCE(p_franchiseeId, '') != '' THEN
            SET @condition = CONCAT(@condition, "fu.franchiseeId = '", p_franchiseeId, "' AND ");
            SET @join = CONCAT(@join, "INNER JOIN tbl_franchisee_users fu ON fu.userProfileId = up.userProfileId ");
        END IF;

        IF COALESCE(p_dealerId, '') != '' THEN
            SET @condition = CONCAT(@condition, "du.dealerId = '", p_dealerId, "' AND ");
            SET @join = CONCAT(@join, "INNER JOIN tbl_dealer_user du ON du.userProfileId = up.userProfileId ");
        END IF;

        IF COALESCE(p_roleId, '') != '' THEN
            SET @condition = CONCAT(@condition, "ur.roleId = '", p_roleId, "' AND ");
        END IF;

        IF COALESCE(p_firstName, '') != '' THEN
            SET @condition = CONCAT(@condition, "up.firstName LIKE '%", p_firstName, "%' AND ");
        END IF;

        IF COALESCE(p_middleName, '') != '' THEN
            SET @condition = CONCAT(@condition, "up.middleName LIKE '%", p_middleName, "%' AND ");
        END IF;

        IF COALESCE(p_lastName, '') != '' THEN
            SET @condition = CONCAT(@condition, "up.lastName LIKE '%", p_lastName, "%' AND ");
        END IF;

           IF COALESCE(p_fullName, '') != '' THEN
            SET @condition = CONCAT(
                @condition, 
                "CONCAT_WS(' ', up.firstName, up.middleName, up.lastName) LIKE '%", 
                REPLACE(p_fullName, ' ', '%'),  -- Allow partial matches across words
                "%' AND "
            );
        END IF;

        IF COALESCE(p_email, '') != '' THEN
            SET @condition = CONCAT(@condition, "up.email = '", p_email, "' AND ");
        END IF;

        IF COALESCE(p_statusId, '') != '' THEN
            SET @condition = CONCAT(@condition, "up.statusId = '", p_statusId, "' AND ");
        END IF;

        -- Handling salesExecutiveId
        IF COALESCE(p_salesExecutiveId, '') != '' THEN
            SET @condition = CONCAT(@condition, "ds.salesExecutiveId = '", p_salesExecutiveId, "' AND ");
            SET @join = CONCAT(@join, "INNER JOIN tbl_sales ds ON ds.userProfileId = up.userProfileId ");
        END IF;

        -- Remove trailing 'AND'
        SET @condition = TRIM(TRAILING 'AND ' FROM @condition);

        -- Constructing the final SQL query
        SET @sql = CONCAT(
            "SELECT SQL_CALC_FOUND_ROWS DISTINCT up.*, ct.countryName, ct.countryCode, ",
            "st.stateName, st.stateCode, rl.roleId, rl.roleName, rl.roleDescription, ",
            "us.status, ut.userType ",
            "FROM tbl_user_profiles up ",
            "INNER JOIN tbl_countries ct ON ct.countryId = up.countryId ",
            "INNER JOIN tbl_states st ON st.stateId = up.stateId ",
            "INNER JOIN tbl_status us ON us.statusId = up.statusId ",
            "INNER JOIN tbl_user_types ut ON ut.userTypeId = up.userTypeId ",
            "LEFT JOIN tbl_user_roles ur ON ur.userProfileId = up.userProfileId ",
            "LEFT JOIN tbl_roles rl ON rl.roleId = ur.roleId ",
            @join,  -- Dynamically adding the necessary join
            "WHERE ", @condition, 
            "ORDER BY up.userProfileId, rl.roleId ",
            "LIMIT ", (p_currentPage * p_pageSize) - p_pageSize, ",", p_pageSize
        );

        -- Preparing, executing, and deallocating the statement
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Fetching total records
        SET @totalRecords = FOUND_ROWS();

        -- Returning pagination details
        SELECT p_currentPage AS CurrentPage, p_pageSize AS PageSize, @totalRecords AS TotalRecords, CEIL(@totalRecords / p_pageSize) AS TotalPages;

    END;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_searchUserAuditLog` (IN `p_userProfileId` VARCHAR(11), IN `p_email` VARCHAR(50), IN `p_franchiseeId` VARCHAR(11), IN `p_statusId` VARCHAR(11), IN `p_currentPage` INT, IN `p_pageSize` INT)   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
  	START TRANSACTION;
    BEGIN
    	SET @condition = '';
        SET @join = "INNER JOIN (SELECT userProfileId, MAX(actionDateTime) AS maxActionDateTime FROM tbl_user_login_audit GROUP BY userProfileId) recent_actions ON ula.userProfileId = recent_actions.userProfileId AND ula.actionDateTime = recent_actions.maxActionDateTime ";
		IF COALESCE(p_franchiseeId, '') != '' THEN
  			SET @condition = CONCAT(@condition, "fu.franchiseeId = '", p_franchiseeId, "' AND ");
            SET @join =  CONCAT(@join,"INNER JOIN tbl_franchisee_users fu ON fu.userProfileId=ula.userProfileId"); 
		END IF;
        IF COALESCE(p_userProfileId, '') != '' THEN
  			SET @condition = CONCAT(@condition, "up.userProfileId = '", p_userProfileId, "' AND ");
            SET @join = "";
		END IF;
        IF COALESCE(p_email, '') != '' THEN
  			SET @condition = CONCAT(@condition, "up.email = '", p_email, "' AND ");
            SET @join = "";
		END IF;
        IF COALESCE(p_statusId, '') != '' THEN
        	SET @condition = CONCAT(@condition, "up.statusId = '", p_statusId , "' AND ");
        END IF; 
        IF COALESCE(@condition, '') != '' THEN
        	SET @condition = CONCAT(" WHERE ",@condition);
        	SET @condition = TRIM(TRAILING 'AND ' FROM @condition);   
        END IF;
        SET @sql = CONCAT("SELECT SQL_CALC_FOUND_ROWS * FROM tbl_user_login_audit ula INNER JOIN tbl_user_profiles up ON up.userProfileId = ula.userProfileId INNER JOIN tbl_status stat ON stat.statusId=up.statusId ",@join, @condition, "ORDER BY ula.actionDateTime DESC LIMIT ",(p_currentPage*p_pageSize)-p_pageSize,",",p_pageSize);
        
        PREPARE stmt FROM @sql;
		EXECUTE stmt;   
        DEALLOCATE PREPARE stmt;
        SET @totalRecords =  FOUND_ROWS();
        SELECT p_currentPage as CurrentPage,p_pageSize as PageSize,  @totalRecords AS TotalRecords, CEIL(@totalRecords/p_pageSize) as TotalPages;
       
    END; 
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateBrand` (IN `p_brandId` INT, IN `p_brandModifiedDateTime` DATETIME, IN `p_brandName` VARCHAR(255), IN `p_image` VARCHAR(255), IN `p_categoryId` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    BEGIN
        DECLARE lastModifiedDateTime DATETIME;
        DECLARE error_message VARCHAR(256);

        -- Step 1: Get current modified date from DB for concurrency check
        SELECT brandModifiedDateTime INTO lastModifiedDateTime 
        FROM tbl_brand 
        WHERE brandId = p_brandId;

        IF p_brandModifiedDateTime IS NULL OR lastModifiedDateTime IS NULL OR lastModifiedDateTime <> p_brandModifiedDateTime THEN
            SET error_message = "The version did not match. Record already updated by another user. Please refresh the data before updating";
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        ELSE
            -- Step 2: Build dynamic update statement for non-null parameters
            SET @columnsToUpdate = '';

            IF p_brandName IS NOT NULL THEN
                SET @columnsToUpdate = CONCAT(@columnsToUpdate, "brandName = TRIM('", p_brandName, "'),");
            END IF;

            IF p_image IS NOT NULL THEN
                SET @columnsToUpdate = CONCAT(@columnsToUpdate, "image = TRIM('", p_image, "'),");
            END IF;

            IF p_categoryId IS NOT NULL THEN
                SET @columnsToUpdate = CONCAT(@columnsToUpdate, "categoryId = ", p_categoryId, ",");
            END IF;

            -- Remove trailing comma if exists
            IF RIGHT(@columnsToUpdate, 1) = ',' THEN
                SET @columnsToUpdate = LEFT(@columnsToUpdate, LENGTH(@columnsToUpdate) - 1);
            END IF;

            -- Step 3: Prepare and execute dynamic update SQL
            SET @sql = CONCAT("UPDATE tbl_brand SET ", @columnsToUpdate, ", brandModifiedDateTime = NOW() WHERE brandId = ", p_brandId);

            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            -- Optional: Add handling for related tables, e.g. brand categories if needed
            -- Example:
            -- IF p_someOtherParam IS NOT NULL THEN
            --    -- handle related updates here
            -- END IF;
        END IF;
    END;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateNotification` (IN `p_notificationId` INT, IN `p_userProfileId` INT, IN `p_message` TEXT, IN `p_status` INT)   BEGIN
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
   	START TRANSACTION;
    BEGIN
    	
    	DECLARE error_message VARCHAR(256);
    	
       
        	SET @columnsToUpdate = '';
        	IF p_userProfileId IS NOT NULL THEN
			    SET @columnsToUpdate = CONCAT(@columnsToUpdate, "n.userProfileId = ", p_userProfileId, ",");
			END IF;
        	IF p_message IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "n.message = TRIM('", p_message, "'),");
			END IF;
        	
        	IF p_status IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "n.status = ", p_status, ",");
			END IF;
       		
        	SET @sql = CONCAT("UPDATE tbl_notifications n SET ",@columnsToUpdate,"n.notificationModifiedDateTime = NOW() WHERE n.notificationId = ",p_notificationId);
        	PREPARE stmt FROM @sql;
			EXECUTE stmt;   
        	DEALLOCATE PREPARE stmt;
          
	END;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateProductByProductId` (IN `p_productId` INT, IN `p_productName` VARCHAR(255), IN `p_size` VARCHAR(255), IN `p_categoryId` INT, IN `p_brandId` INT, IN `p_image` VARCHAR(255), IN `p_specification` TEXT, IN `p_productModifiedDateTime` DATETIME)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    

    START TRANSACTION;
    BEGIN

    DECLARE lastModifiedDateTime DATETIME;
    	DECLARE error_message VARCHAR(256);
        -- Fetch the current modified datetime
        SELECT productModifiedDateTime INTO lastModifiedDateTime
        FROM tbl_product
        WHERE productId = p_productId;

        -- Check optimistic lock
        IF p_productModifiedDateTime IS NULL OR lastModifiedDateTime IS NULL 
           OR lastModifiedDateTime <> p_productModifiedDateTime THEN
            SET error_message = 'The version did not match. Record already updated by another user. Please refresh the data before updating.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        ELSE
            SET @columnsToUpdate = '';

            IF p_productName IS NOT NULL THEN
                SET @columnsToUpdate = CONCAT(@columnsToUpdate, "productName = TRIM('", p_productName, "'),");
            END IF;

            IF p_size IS NOT NULL THEN
                SET @columnsToUpdate = CONCAT(@columnsToUpdate, "size = TRIM('", p_size, "'),");
            END IF;

            IF p_categoryId IS NOT NULL THEN
                SET @columnsToUpdate = CONCAT(@columnsToUpdate, "categoryId = ", p_categoryId, ",");
            END IF;

            IF p_brandId IS NOT NULL THEN
                SET @columnsToUpdate = CONCAT(@columnsToUpdate, "brandId = ", p_brandId, ",");
            END IF;

            IF p_image IS NOT NULL THEN
                SET @columnsToUpdate = CONCAT(@columnsToUpdate, "image = TRIM('", p_image, "'),");
            END IF;

            IF p_specification IS NOT NULL THEN
                SET @columnsToUpdate = CONCAT(@columnsToUpdate, "specification = '", p_specification, "',");
            END IF;

            -- Always update modified datetime
            SET @sql = CONCAT(
                "UPDATE tbl_product SET ", 
                @columnsToUpdate, 
                "productModifiedDateTime = NOW() ",
                "WHERE productId = ", p_productId
            );

            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    END;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateRole` (IN `p_roleId` INT, IN `p_userTypeId` INT, IN `p_roleName` VARCHAR(50), IN `p_roleDescription` VARCHAR(256), IN `p_roleModifiedDateTime` DATETIME)   BEGIN
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
   	START TRANSACTION;
    BEGIN
    	DECLARE lastModifiedDateTime DATETIME;
    	DECLARE error_message VARCHAR(256);
    	SELECT roleModifiedDateTime INTO lastModifiedDateTime FROM tbl_roles WHERE roleId = p_roleId;
        IF p_roleModifiedDateTime IS NULL OR lastModifiedDateTime IS NULL OR lastModifiedDateTime <> p_roleModifiedDateTime THEN
        	SET error_message = "The version did not match. record already updated by another user. Please refresh the data before updating";
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        ELSE
        	SET @columnsToUpdate = '';
        	IF p_roleName IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "rl.roleName = TRIM('", p_roleName, "'),");
			END IF;
        	IF p_roleDescription IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "rl.roleDescription = TRIM('", p_roleDescription, "'),");
			END IF;
            
        	SET @sql = CONCAT("UPDATE tbl_roles rl SET ",@columnsToUpdate,"rl.roleModifiedDateTime = NOW() WHERE rl.roleId = ",p_roleId);
        	PREPARE stmt FROM @sql;
			EXECUTE stmt;   
        	DEALLOCATE PREPARE stmt;
            
           IF p_userTypeId IS NOT NULL THEN
  				DELETE FROM tbl_role_groups WHERE roleId = p_roleId;
                INSERT INTO tbl_role_groups(userTypeId,roleId) VALUES(p_userTypeId,p_roleId);
			END IF;            
    	END IF;
	END;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateUserProfile` (IN `p_userProfileId` INT, IN `p_firstName` VARCHAR(50), IN `p_middleName` VARCHAR(50), IN `p_lastName` VARCHAR(50), IN `p_dateOfBirth` DATETIME, IN `p_addressLine1` VARCHAR(300), IN `p_addressLine2` VARCHAR(300), IN `p_stateId` INT, IN `p_countryId` INT, IN `p_zipOrPostCode` VARCHAR(20), IN `p_email` VARCHAR(50), IN `p_phone` VARCHAR(20), IN `p_mobile` VARCHAR(20), IN `p_password` VARCHAR(256), IN `p_statusId` INT, IN `p_userTypeId` INT, IN `p_roleId` INT, IN `p_userProfileModifiedDateTime` DATETIME, IN `p_ipAddress` VARCHAR(255))   BEGIN
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
   	START TRANSACTION;
    BEGIN
    	DECLARE lastModifiedDateTime DATETIME;
    	DECLARE error_message VARCHAR(256);
    	SELECT userProfileModifiedDateTime INTO lastModifiedDateTime FROM tbl_user_profiles WHERE userProfileId = p_userProfileId;
        IF p_userProfileModifiedDateTime IS NULL OR lastModifiedDateTime IS NULL OR lastModifiedDateTime <> p_userProfileModifiedDateTime THEN
        	SET error_message = "The version did not match. record already updated by another user. Please refresh the data before updating";
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        ELSE
        	SET @columnsToUpdate = '';
        	IF p_firstName IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.firstName = TRIM('", p_firstName, "'),");
			END IF;
        	IF p_middleName IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.middleName = TRIM('", p_middleName, "'),");
			END IF;
        	IF p_lastName IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.lastName = TRIM('", p_lastName, "'),");
			END IF;
        	IF p_dateOfBirth IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.dateOfBirth = '", p_dateOfBirth, "',");
			END IF;
        	IF p_addressLine1 IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.addressLine1 = TRIM('", p_addressLine1, "'),");
			END IF;
        	IF p_addressLine2 IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.addressLine2 = TRIM('", p_addressLine2, "'),");
			END IF;
        	IF p_stateId IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.stateId = ", p_stateId, ",");
			END IF;
       		IF p_countryId IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.countryId = ", p_countryId, ",");
			END IF;
        	IF p_zipOrPostCode IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.zipOrPostCode = TRIM('", p_zipOrPostCode, "'),");
			END IF;
        	IF p_email IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.email = TRIM('", p_email, "'),");
			END IF;
        	IF p_phone IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.phone = TRIM('", p_phone, "'),");
			END IF;
        	IF p_mobile IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.mobile = TRIM('", p_mobile, "'),");
			END IF;
        	IF p_password IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.password = TRIM('", p_password, "'),");
			END IF;
        	IF p_statusId IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.statusId = ", p_statusId, ",");
			END IF;
        	IF p_userTypeId IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.userTypeId = ", p_userTypeId, ",");
			END IF;      
			IF p_ipAddress IS NOT NULL THEN
  				SET @columnsToUpdate = CONCAT(@columnsToUpdate, "up.ipAddress = TRIM('", p_ipAddress, "'),");
			END IF;  	 

        	SET @sql = CONCAT("UPDATE tbl_user_profiles up SET ",@columnsToUpdate,"up.userProfileModifiedDateTime = NOW() WHERE up.userProfileId = ",p_userProfileId);
        	PREPARE stmt FROM @sql;
			EXECUTE stmt;   
        	DEALLOCATE PREPARE stmt;
            
           IF p_roleId IS NOT NULL THEN
  				DELETE FROM tbl_user_roles WHERE userProfileId = p_userProfileId;
                INSERT INTO tbl_user_roles(userProfileId,roleId) VALUES(p_userProfileId,p_roleId);
			END IF;
    	END IF;
	END;  
    COMMIT;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_getPath` (`p_btreeNode` VARCHAR(1000)) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
SET @parents := CONCAT('1',p_btreeNode);
SET @lastCommaIndex := LENGTH(@parents) - LENGTH(REPLACE(@parents, ',', ''));
SET @parents := SUBSTRING_INDEX(@parents, ',', @lastCommaIndex);
SELECT  GROUP_CONCAT(resourceName SEPARATOR '/') AS path INTO @Path FROM tbl_resources WHERE FIND_IN_SET(resourceId,@parents);
RETURN  @Path;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_validate_tbl_categories_delete` (`p_categoryId` INT) RETURNS INT(11)  BEGIN
    DECLARE imageId INT;

    -- Step 1: Retrieve the imageId from tbl_categories
    SELECT imageId INTO imageId FROM tbl_categories WHERE categoryId = p_categoryId;

    -- Step 2: Delete from tbl_category_mapping where subCategoryId matches the categoryId
    DELETE FROM tbl_category_mapping WHERE subCategoryId = p_categoryId;

    -- Step 4: Delete the image from tbl_images using the retrieved imageId
    IF imageId IS NOT NULL THEN
        DELETE FROM tbl_images WHERE imageId = imageId;
    END IF;

    -- Return 1 to indicate success
    RETURN 1;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_validate_tbl_content_group_delete` (`p_contentGroupId` INT) RETURNS INT(11)  BEGIN
   DELETE FROM tbl_content_group_users WHERE contentGroupId = p_contentGroupId;   
   DELETE FROM tbl_content_group_resources WHERE contentGroupId = p_contentGroupId;       
   RETURN 1; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_validate_tbl_franchisee_delete` (`p_franchiseeId` INT) RETURNS INT(11)  BEGIN
   DELETE FROM tbl_franchisee_users WHERE franchiseeId = p_franchiseeId; 
   DELETE FROM tbl_content_group WHERE franchiseeId = p_franchiseeId;
   RETURN 1; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_validate_tbl_franchisee_insert_update` (`p_stateId` INT, `p_countryId` INT) RETURNS INT(11) NO SQL BEGIN
    DECLARE state_count INT;
    DECLARE error_message VARCHAR(256);
    -- Check if state and country exists
    SELECT COUNT(st.stateId) INTO state_count FROM tbl_states st
    INNER JOIN tbl_countries ct ON ct.countryId=st.countryId WHERE st.stateId = p_stateId AND ct.countryId = p_countryId;
    IF state_count = 0 THEN
    	SET error_message = CONCAT("State Id ", CAST(p_stateId AS CHAR), " does not exist in the country ", CAST(p_countryId AS CHAR),"  or country does not exist");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;
    RETURN 1; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_validate_tbl_permissions_delete` (`p_permissionId` INT) RETURNS INT(11) NO SQL BEGIN
	/*Remove the permission assinged to all roles before deleting the original permission from permission table*/
    DELETE FROM tbl_role_permissions WHERE permissionId = p_permissionId;
   
   RETURN 1; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_validate_tbl_resources_delete` (`p_resourceId` INT) RETURNS INT(11)  BEGIN
   DELETE FROM tbl_content_group_resources WHERE resourceId = p_resourceId;   
   RETURN 1; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_validate_tbl_resources_insert_update` (`p_parentId` INT, `p_resourceName` VARCHAR(256), `p_resourceType` VARCHAR(10)) RETURNS INT(11)  BEGIN
   DECLARE parent_count INT;
    DECLARE folder_count INT;
    DECLARE error_message VARCHAR(256);
    -- Check if ParentId exists
    SELECT COUNT(resourceId) INTO parent_count FROM tbl_resources WHERE resourceId = p_parentId;
    IF parent_count = 0 THEN
    	SET error_message = CONCAT('ParentId ''', CAST(p_parentId AS CHAR), ''' does not exist');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    ELSE
        -- Check if the folder already exists
        SELECT COUNT(resourceId) INTO folder_count FROM tbl_resources WHERE ParentId = p_parentId AND LOWER(TRIM(resourceName)) = LOWER(TRIM(p_resourceName)) AND LOWER(TRIM(resourceType))  = LOWER(TRIM(p_resourceType)) ;
        IF folder_count > 0 THEN
            SET error_message = CONCAT(p_resourceType, ' ''', p_resourceName, ''' already exists ');
       		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
    RETURN 1; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_validate_tbl_roles_delete` (`p_roleId` INT) RETURNS INT(11) NO SQL BEGIN
	DELETE FROM tbl_role_permissions WHERE roleId = p_roleId;   
    DELETE FROM tbl_role_groups WHERE roleId = p_roleId;   
    /*Remove the role assinged to all users before deleting the original role from role table*/
    DELETE FROM tbl_user_roles WHERE roleId = p_roleId;   
   RETURN 1; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_validate_tbl_user_profiles_delete` (`p_userProfileId` INT) RETURNS INT(11)  BEGIN
	/*Remove all roles of the users before delete*/
    DELETE FROM tbl_user_roles WHERE userProfileId = p_userProfileId;
   /*Remove from franchisee users before delete*/

   RETURN 1; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_validate_tbl_user_profiles_insert_update` (`p_stateId` INT, `p_countryId` INT) RETURNS INT(11)  BEGIN
    DECLARE state_count INT;
    DECLARE error_message VARCHAR(256);
    -- Check if state and country exists
    SELECT COUNT(st.stateId) INTO state_count FROM tbl_states st
    INNER JOIN tbl_countries ct ON ct.countryId=st.countryId WHERE st.stateId = p_stateId AND ct.countryId = p_countryId;
    IF state_count = 0 THEN
    	SET error_message = CONCAT("State Id ", CAST(p_stateId AS CHAR), " does not exist in the country ", CAST(p_countryId AS CHAR),"  or country does not exist");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;
    RETURN 1; 
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_brand`
--

CREATE TABLE `tbl_brand` (
  `brandId` int(11) NOT NULL,
  `brandName` varchar(255) NOT NULL,
  `categoryId` int(11) NOT NULL,
  `image` varchar(255) NOT NULL,
  `brandModifiedDateTime` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_category`
--

CREATE TABLE `tbl_category` (
  `categoryId` int(11) NOT NULL,
  `categoryName` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_category`
--

INSERT INTO `tbl_category` (`categoryId`, `categoryName`) VALUES
(1, 'Confectionery items'),
(2, 'Coffee and Beverages'),
(3, 'Baby Foods'),
(4, 'Pet Foods');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_countries`
--

CREATE TABLE `tbl_countries` (
  `countryId` int(11) NOT NULL,
  `countryName` varchar(60) NOT NULL,
  `countryCode` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `tbl_countries`
--

INSERT INTO `tbl_countries` (`countryId`, `countryName`, `countryCode`) VALUES
(1, 'Afghanistan', 'AF'),
(2, 'Albania', 'AL'),
(3, 'Algeria', 'DZ'),
(4, 'Andorra', 'AD'),
(5, 'Angola', 'AO'),
(6, 'Antigua and Barbuda', 'AG'),
(7, 'Argentina', 'AR'),
(8, 'Armenia', 'AM'),
(9, 'Australia', 'AU'),
(10, 'Austria', 'AT'),
(11, 'Azerbaijan', 'AZ'),
(12, 'Bahamas', 'BS'),
(13, 'Bahrain', 'BH'),
(14, 'Bangladesh', 'BD'),
(15, 'Barbados', 'BB'),
(16, 'Belarus', 'BY'),
(17, 'Belgium', 'BE'),
(18, 'Belize', 'BZ'),
(19, 'Benin', 'BJ'),
(20, 'Bhutan', 'BT'),
(21, 'Bolivia', 'BO'),
(22, 'Bosnia and Herzegovina', 'BA'),
(23, 'Botswana', 'BW'),
(24, 'Brazil', 'BR'),
(25, 'Brunei', 'BN'),
(26, 'Bulgaria', 'BG'),
(27, 'Burkina Faso', 'BF'),
(28, 'Burundi', 'BI'),
(29, 'Cabo Verde', 'CV'),
(30, 'Cambodia', 'KH'),
(31, 'Cameroon', 'CM'),
(32, 'Canada', 'CA'),
(33, 'Central African Republic', 'CF'),
(34, 'Chad', 'TD'),
(35, 'Chile', 'CL'),
(36, 'China', 'CN'),
(37, 'Colombia', 'CO'),
(38, 'Comoros', 'KM'),
(39, 'Congo', 'CG'),
(40, 'Costa Rica', 'CR'),
(41, 'Croatia', 'HR'),
(42, 'Cuba', 'CU'),
(43, 'Cyprus', 'CY'),
(44, 'Czech Republic', 'CZ'),
(45, 'Denmark', 'DK'),
(46, 'Djibouti', 'DJ'),
(47, 'Dominica', 'DM'),
(48, 'Dominican Republic', 'DO'),
(49, 'East Timor', 'TL'),
(50, 'Ecuador', 'EC'),
(51, 'Egypt', 'EG'),
(52, 'El Salvador', 'SV'),
(53, 'Equatorial Guinea', 'GQ'),
(54, 'Eritrea', 'ER'),
(55, 'Estonia', 'EE'),
(56, 'Eswatini', 'SZ'),
(57, 'Ethiopia', 'ET'),
(58, 'Fiji', 'FJ'),
(59, 'Finland', 'FI'),
(60, 'France', 'FR'),
(61, 'Gabon', 'GA'),
(62, 'Gambia', 'GM'),
(63, 'Georgia', 'GE'),
(64, 'Germany', 'DE'),
(65, 'Ghana', 'GH'),
(66, 'Greece', 'GR'),
(67, 'Grenada', 'GD'),
(68, 'Guatemala', 'GT'),
(69, 'Guinea', 'GN'),
(70, 'Guinea-Bissau', 'GW'),
(71, 'Guyana', 'GY'),
(72, 'Haiti', 'HT'),
(73, 'Honduras', 'HN'),
(74, 'Hungary', 'HU'),
(75, 'Iceland', 'IS'),
(76, 'India', 'IN'),
(77, 'Indonesia', 'ID'),
(78, 'Iran', 'IR'),
(79, 'Iraq', 'IQ'),
(80, 'Ireland', 'IE'),
(81, 'Israel', 'IL'),
(82, 'Italy', 'IT'),
(83, 'Jamaica', 'JM'),
(84, 'Japan', 'JP'),
(85, 'Jordan', 'JO'),
(86, 'Kazakhstan', 'KZ'),
(87, 'Kenya', 'KE'),
(88, 'Kiribati', 'KI'),
(89, 'Korea, North', 'KP'),
(90, 'Korea, South', 'KR'),
(91, 'Kosovo', 'XK'),
(92, 'Kuwait', 'KW'),
(93, 'Kyrgyzstan', 'KG'),
(94, 'Laos', 'LA'),
(95, 'Latvia', 'LV'),
(96, 'Lebanon', 'LB'),
(97, 'Lesotho', 'LS'),
(98, 'Liberia', 'LR'),
(99, 'Libya', 'LY'),
(100, 'Liechtenstein', 'LI'),
(101, 'Lithuania', 'LT'),
(102, 'Luxembourg', 'LU'),
(103, 'Madagascar', 'MG'),
(104, 'Malawi', 'MW'),
(105, 'Malaysia', 'MY'),
(106, 'Maldives', 'MV'),
(107, 'Mali', 'ML'),
(108, 'Malta', 'MT'),
(109, 'Marshall Islands', 'MH'),
(110, 'Mauritania', 'MR'),
(111, 'Mauritius', 'MU'),
(112, 'Mexico', 'MX'),
(113, 'Micronesia', 'FM'),
(114, 'Moldova', 'MD'),
(115, 'Monaco', 'MC'),
(116, 'Mongolia', 'MN'),
(117, 'Montenegro', 'ME'),
(118, 'Morocco', 'MA'),
(119, 'Mozambique', 'MZ'),
(120, 'Myanmar', 'MM'),
(121, 'Namibia', 'NA'),
(122, 'Nauru', 'NR'),
(123, 'Nepal', 'NP'),
(124, 'Netherlands', 'NL'),
(125, 'New Zealand', 'NZ'),
(126, 'Nicaragua', 'NI'),
(127, 'Niger', 'NE'),
(128, 'Nigeria', 'NG'),
(129, 'North Macedonia', 'MK'),
(130, 'Norway', 'NO'),
(131, 'Oman', 'OM'),
(132, 'Pakistan', 'PK'),
(133, 'Palau', 'PW'),
(134, 'Palestine', 'PS'),
(135, 'Panama', 'PA'),
(136, 'Papua New Guinea', 'PG'),
(137, 'Paraguay', 'PY'),
(138, 'Peru', 'PE'),
(139, 'Philippines', 'PH'),
(140, 'Poland', 'PL'),
(141, 'Portugal', 'PT'),
(142, 'Qatar', 'QA'),
(143, 'Romania', 'RO'),
(144, 'Russia', 'RU'),
(145, 'Rwanda', 'RW'),
(146, 'Saint Kitts and Nevis', 'KN'),
(147, 'Saint Lucia', 'LC'),
(148, 'Saint Vincent and the Grenadines', 'VC'),
(149, 'Samoa', 'WS'),
(150, 'San Marino', 'SM'),
(151, 'Sao Tome and Principe', 'ST'),
(152, 'Saudi Arabia', 'SA'),
(153, 'Senegal', 'SN'),
(154, 'Serbia', 'RS'),
(155, 'Seychelles', 'SC'),
(156, 'Sierra Leone', 'SL'),
(157, 'Singapore', 'SG'),
(158, 'Slovakia', 'SK'),
(159, 'Slovenia', 'SI'),
(160, 'Solomon Islands', 'SB'),
(161, 'Somalia', 'SO'),
(162, 'South Africa', 'ZA'),
(163, 'South Sudan', 'SS'),
(164, 'Spain', 'ES'),
(165, 'Sri Lanka', 'LK'),
(166, 'Sudan', 'SD'),
(167, 'Suriname', 'SR'),
(168, 'Sweden', 'SE'),
(169, 'Switzerland', 'CH'),
(170, 'Syria', 'SY'),
(171, 'Taiwan', 'TW'),
(172, 'Tajikistan', 'TJ'),
(173, 'Tanzania', 'TZ'),
(174, 'Thailand', 'TH'),
(175, 'Togo', 'TG'),
(176, 'Tonga', 'TO'),
(177, 'Trinidad and Tobago', 'TT'),
(178, 'Tunisia', 'TN'),
(179, 'Turkey', 'TR'),
(180, 'Turkmenistan', 'TM'),
(181, 'Tuvalu', 'TV'),
(182, 'Uganda', 'UG'),
(183, 'Ukraine', 'UA'),
(184, 'United Arab Emirates', 'AE'),
(185, 'United Kingdom', 'GB'),
(186, 'United States', 'US'),
(187, 'Uruguay', 'UY'),
(188, 'Uzbekistan', 'UZ'),
(189, 'Vanuatu', 'VU'),
(190, 'Vatican City', 'VA'),
(191, 'Venezuela', 'VE'),
(192, 'Vietnam', 'VN'),
(193, 'Yemen', 'YE'),
(194, 'Zambia', 'ZM'),
(195, 'Zimbabwe', 'ZW');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_email_verification`
--

CREATE TABLE `tbl_email_verification` (
  `emailVerificationId` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `verificationCode` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_email_verification`
--

INSERT INTO `tbl_email_verification` (`emailVerificationId`, `email`, `verificationCode`) VALUES
(2, 'mushthaquemtcxxxxx@gmail.com', 'p2eOa6mKOv7j'),
(3, 'mushthaquemtc@gmail.com', '423116');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_notifications`
--

CREATE TABLE `tbl_notifications` (
  `notificationId` int(11) NOT NULL,
  `userProfileId` int(11) NOT NULL,
  `message` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  `notificationModifiedDateTime` datetime NOT NULL DEFAULT current_timestamp(),
  `type` varchar(20) NOT NULL,
  `navigationId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_notifications`
--

INSERT INTO `tbl_notifications` (`notificationId`, `userProfileId`, `message`, `status`, `notificationModifiedDateTime`, `type`, `navigationId`) VALUES
(1, 174, 'Great news! You have unlocked Milestone Milestone1. Keep going for more rewards! ?', 0, '2025-01-30 14:17:03', 'Reward_Notifications', NULL),
(2, 56, 'Great news! You have unlocked Milestone Milestone1. Keep going for more rewards! ?', 0, '2025-01-30 14:17:03', 'Reward_Notifications', NULL),
(3, 173, 'Great news! You have unlocked Milestone Milestone1. Keep going for more rewards! ?', 0, '2025-01-30 14:17:03', 'Reward_Notifications', NULL),
(4, 175, 'Great news! You have unlocked Milestone Milestone1. Keep going for more rewards! ?', 0, '2025-01-30 14:17:03', 'Reward_Notifications', NULL),
(5, 173, 'Great news! You have unlocked Milestone Milestone 2. Keep going for more rewards! ?', 0, '2025-01-30 14:17:03', 'Reward_Notifications', NULL),
(6, 178, 'Welcome to ABL Connect, mushthaque mtc jouhar! Get started now and unlock exciting rewards.', 0, '2025-01-30 14:18:12', 'Auth_Notifications', NULL),
(7, 173, 'Update: Your Invoice INv45453 has been approved.', 0, '2025-04-01 11:03:52', 'Invoice_Notification', 6);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_permissions`
--

CREATE TABLE `tbl_permissions` (
  `permissionId` int(11) NOT NULL,
  `permissionName` varchar(50) NOT NULL,
  `permissionDescription` varchar(256) DEFAULT NULL,
  `lastModifiedDateTime` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_permissions`
--

INSERT INTO `tbl_permissions` (`permissionId`, `permissionName`, `permissionDescription`, `lastModifiedDateTime`) VALUES
(1, 'APP_LOGIN', 'Provide login access to application', '2023-07-17 22:55:48'),
(2, 'DASHBOARD_VIEW_ADMIN', 'Provide access to view admin dashboard', '2023-07-17 22:56:05'),
(4, 'RESOURCE_MODIFY', 'Provide access to add, view and modify resources', '2023-07-17 23:00:29'),
(5, 'RESOURCE_VIEW', 'Provide access to view resources', '2023-07-17 23:05:43'),
(6, 'RESOURCE_DELETE', 'Provide access to delete resources', '2023-07-17 23:06:00'),
(7, 'USER_MODIFY', 'Provide access to add, view and modify users', '2023-07-17 23:10:03'),
(8, 'USER_VIEW', 'Provide access to view users', '2023-07-17 23:11:00'),
(9, 'USER_DELETE', 'Provide access to delete users', '2023-07-17 23:11:43'),
(10, 'DEALER_USER_MODIFY', 'Provide access to add, view and modify dealer users', '2023-07-17 23:12:41'),
(11, 'DEALER_USER_VIEW', 'Provide access to view dealer users', '2023-07-17 23:13:00'),
(12, 'DEALER_USER_DELETE', 'Provide access to delete dealer users', '2023-07-17 23:13:25'),
(13, 'DEALER_MODIFY', 'Provide access to add, view and modify dealer', '2023-07-17 23:16:45'),
(14, 'DEALER_VIEW', 'Provide access to view dealer', '2023-07-17 23:17:21'),
(15, 'DEALER_DELETE', 'Provide access to delete dealer', '2023-07-17 23:17:41'),
(16, 'USER_STATUS_ALERT_VIEW', 'Provide access to receive and view user status alerts', '2023-07-17 23:23:37'),
(17, 'ROLE_MODIFY', 'Provide access to add, view and modify corporate roles', '2023-07-17 23:24:53'),
(18, 'ROLE_DELETE', 'Provide access to delete corporate roles', '2023-07-17 23:25:24'),
(19, 'ROLE_VIEW', 'Provide access to view roles', '2023-07-17 23:26:05'),
(20, 'DASHBOARD_VIEW_CONTENT', 'Provide access to view content dashboard', '2023-07-17 23:26:25'),
(21, 'MILESTONE_MODIFY', 'Provide access to modify milestone', '2023-09-09 10:19:58'),
(22, 'MILESTONE_VIEW', 'Provide access to view milestones', '2023-09-09 10:21:02'),
(23, 'MILESTONE_DELETE', 'Provide access to delete milestone', '2023-09-18 10:11:47'),
(24, 'REWARD_MODIFY', 'Provide access to create and update rewards', '2023-09-18 10:11:47'),
(25, 'REWARD_VIEW', 'Provide access to view rewards', '2023-09-18 10:13:04'),
(26, 'IMPERSONATE_USER', 'Provide privileges to impersonate a user ', '2023-10-05 08:05:42'),
(27, 'ALLOW_OFFLINE_MODE', 'Provide access to download and store resources on local devices and login when not connected to internet', '2023-10-28 00:04:47'),
(28, 'REWARD_DELETE', 'Provide access to delete rewards', '2025-01-29 10:16:46'),
(29, 'SALES_MODIFY', 'Provide access to modify sales', '2025-01-29 10:22:51'),
(30, 'SALES_VIEW', 'Provide access to view sales', '2025-01-29 10:22:51'),
(31, 'SALES_DELETE', 'Provide access to delete sales', '2025-01-29 10:24:07');

--
-- Triggers `tbl_permissions`
--
DELIMITER $$
CREATE TRIGGER `tr_validate_permissions_delete` BEFORE DELETE ON `tbl_permissions` FOR EACH ROW BEGIN
	DECLARE result INT;
   	SELECT fn_validate_tbl_permissions_delete(OLD.permissionId) INTO result;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_product`
--

CREATE TABLE `tbl_product` (
  `productId` int(11) NOT NULL,
  `productName` varchar(255) NOT NULL,
  `size` varchar(255) NOT NULL,
  `categoryId` int(11) NOT NULL,
  `brandId` int(11) NOT NULL,
  `image` varchar(255) NOT NULL,
  `specification` text NOT NULL,
  `productModifiedDateTime` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_resources`
--

CREATE TABLE `tbl_resources` (
  `resourceId` int(11) NOT NULL,
  `resourceName` varchar(256) NOT NULL,
  `resourceType` varchar(10) NOT NULL,
  `extension` varchar(10) DEFAULT NULL,
  `contentType` varchar(50) DEFAULT NULL,
  `size` double DEFAULT NULL,
  `parentId` int(11) NOT NULL,
  `btreeNode` text NOT NULL,
  `lastModifiedDateTime` datetime NOT NULL DEFAULT current_timestamp(),
  `lastModifiedUserProfileId` int(11) NOT NULL,
  `statusId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_resources`
--

INSERT INTO `tbl_resources` (`resourceId`, `resourceName`, `resourceType`, `extension`, `contentType`, `size`, `parentId`, `btreeNode`, `lastModifiedDateTime`, `lastModifiedUserProfileId`, `statusId`) VALUES
(1, 'DocBase', 'Folder', NULL, NULL, NULL, 0, '', '2024-11-11 14:38:39', 1, 1),
(2, 'folder 2', 'Folder', NULL, NULL, NULL, 1, ',2', '2025-02-06 11:21:08', 56, 1),
(3, 'largeGift.jpg', 'File', 'jpg', NULL, NULL, 1, ',3', '2025-02-06 18:46:52', 56, 1);

--
-- Triggers `tbl_resources`
--
DELIMITER $$
CREATE TRIGGER `tr_validate_insert` BEFORE INSERT ON `tbl_resources` FOR EACH ROW BEGIN
	DECLARE result INT;
  SELECT fn_validate_tbl_resources_insert_update(NEW.ParentId,NEW.resourceName,NEW.resourceType) INTO result;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_validate_update` BEFORE UPDATE ON `tbl_resources` FOR EACH ROW BEGIN
	IF NEW.ParentId != OLD.ParentId OR  NEW.resourceName != OLD.resourceName THEN
    BEGIN
    	DECLARE result INT;
   	 	SELECT fn_validate_tbl_resources_insert_update(NEW.ParentId,NEW.resourceName,NEW.resourceType) INTO result;
    END;
    END IF;     
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_roles`
--

CREATE TABLE `tbl_roles` (
  `roleId` int(11) NOT NULL,
  `roleName` varchar(50) NOT NULL,
  `roleDescription` varchar(256) DEFAULT NULL,
  `roleModifiedDateTime` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_roles`
--

INSERT INTO `tbl_roles` (`roleId`, `roleName`, `roleDescription`, `roleModifiedDateTime`) VALUES
(1, 'Administrator', 'User who have highest privileges to control the entire FMS system', '2023-12-11 08:05:14'),
(2, 'Sales Executives', 'Sales Executive who manages the store customers', '2023-10-05 01:22:01'),
(3, 'Customer', 'The end user is the person who uses the system', '2023-12-06 19:15:49');

--
-- Triggers `tbl_roles`
--
DELIMITER $$
CREATE TRIGGER `tr_validate_roles_delete` BEFORE DELETE ON `tbl_roles` FOR EACH ROW BEGIN
	DECLARE result INT;
   	SELECT fn_validate_tbl_roles_delete(OLD.roleId) INTO result;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_role_groups`
--

CREATE TABLE `tbl_role_groups` (
  `userTypeId` int(11) NOT NULL,
  `roleId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `tbl_role_groups`
--

INSERT INTO `tbl_role_groups` (`userTypeId`, `roleId`) VALUES
(1, 1),
(1, 2),
(2, 3);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_role_permissions`
--

CREATE TABLE `tbl_role_permissions` (
  `roleId` int(11) NOT NULL,
  `permissionId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_role_permissions`
--

INSERT INTO `tbl_role_permissions` (`roleId`, `permissionId`) VALUES
(1, 1),
(1, 2),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11),
(1, 12),
(1, 13),
(1, 14),
(1, 15),
(1, 16),
(1, 17),
(1, 18),
(1, 19),
(1, 20),
(1, 21),
(1, 22),
(1, 23),
(1, 24),
(1, 26),
(1, 28),
(1, 29),
(1, 30),
(1, 31),
(2, 1),
(2, 5),
(2, 7),
(2, 8),
(2, 11),
(2, 14),
(2, 29),
(2, 30),
(3, 1),
(3, 4),
(3, 5),
(3, 6),
(3, 7),
(3, 8),
(3, 14),
(3, 22),
(3, 24),
(3, 25),
(3, 29),
(3, 30);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_states`
--

CREATE TABLE `tbl_states` (
  `stateId` int(11) NOT NULL,
  `countryId` int(11) NOT NULL,
  `stateName` varchar(100) NOT NULL,
  `stateCode` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_states`
--

INSERT INTO `tbl_states` (`stateId`, `countryId`, `stateName`, `stateCode`) VALUES
(1, 9, 'Australian Capital Territory', 'ACT'),
(2, 9, 'New South Wales', 'NSW'),
(3, 9, 'Northern Territory', 'NT'),
(4, 9, 'Queensland', 'QLD'),
(5, 9, 'South Australia', 'SA'),
(6, 9, 'Tasmania', 'TAS'),
(7, 9, 'Victoria', 'VIC'),
(8, 9, 'Western Australia', 'WA'),
(9, 10, 'Burgenland', 'BUR'),
(10, 10, 'Carinthia', 'KTN'),
(11, 10, 'Lower Austria', 'NOE'),
(12, 10, 'Upper Austria', 'OBE'),
(13, 10, 'Salzburg', 'SBG'),
(14, 10, 'Styria', 'STM'),
(15, 10, 'Tyrol', 'TYR'),
(16, 10, 'Vorarlberg', 'VOR'),
(17, 10, 'Vienna', 'VIE'),
(18, 17, 'Brussels-Capital Region', 'BRU'),
(19, 17, 'Flemish Brabant', 'VBR'),
(20, 17, 'Walloon Brabant', 'WBR'),
(21, 17, 'Antwerp', 'ANT'),
(22, 17, 'East Flanders', 'VOV'),
(23, 17, 'West Flanders', 'VWV'),
(24, 17, 'Hainaut', 'WHT'),
(25, 17, 'Liège', 'WLG'),
(26, 17, 'Limburg', 'VLI'),
(27, 17, 'Luxembourg', 'WLX'),
(28, 17, 'Namur', 'WNA'),
(29, 76, 'Andhra Pradesh', 'AP'),
(30, 76, 'Arunachal Pradesh', 'AR'),
(31, 76, 'Assam', 'AS'),
(32, 76, 'Bihar', 'BR'),
(33, 76, 'Chhattisgarh', 'CG'),
(34, 76, 'Goa', 'GA'),
(35, 76, 'Gujarat', 'GJ'),
(36, 76, 'Haryana', 'HR'),
(37, 76, 'Himachal Pradesh', 'HP'),
(38, 76, 'Jharkhand', 'JH'),
(39, 76, 'Karnataka', 'KA'),
(40, 76, 'Kerala', 'KL'),
(41, 76, 'Madhya Pradesh', 'MP'),
(42, 76, 'Maharashtra', 'MH'),
(43, 76, 'Manipur', 'MN'),
(44, 76, 'Meghalaya', 'ML'),
(45, 76, 'Mizoram', 'MZ'),
(46, 76, 'Nagaland', 'NL'),
(47, 76, 'Odisha', 'OR'),
(48, 76, 'Punjab', 'PB'),
(49, 76, 'Rajasthan', 'RJ'),
(50, 76, 'Sikkim', 'SK'),
(51, 76, 'Tamil Nadu', 'TN'),
(52, 76, 'Telangana', 'TG'),
(53, 76, 'Tripura', 'TR'),
(54, 76, 'Uttar Pradesh', 'UP'),
(55, 76, 'Uttarakhand', 'UK'),
(56, 76, 'West Bengal', 'WB'),
(57, 186, 'Alabama', 'AL'),
(58, 186, 'Alaska', 'AK'),
(59, 186, 'Arizona', 'AZ'),
(60, 186, 'Arkansas', 'AR'),
(61, 186, 'California', 'CA'),
(62, 186, 'Colorado', 'CO'),
(63, 186, 'Connecticut', 'CT'),
(64, 186, 'Delaware', 'DE'),
(65, 186, 'Florida', 'FL'),
(66, 186, 'Georgia', 'GA'),
(67, 186, 'Hawaii', 'HI'),
(68, 186, 'Idaho', 'ID'),
(69, 186, 'Illinois', 'IL'),
(70, 186, 'Indiana', 'IN'),
(71, 186, 'Iowa', 'IA'),
(72, 186, 'Kansas', 'KS'),
(73, 186, 'Kentucky', 'KY'),
(74, 186, 'Louisiana', 'LA'),
(75, 186, 'Maine', 'ME'),
(76, 186, 'Maryland', 'MD'),
(77, 186, 'Massachusetts', 'MA'),
(78, 186, 'Michigan', 'MI'),
(79, 186, 'Minnesota', 'MN'),
(80, 186, 'Mississippi', 'MS'),
(81, 186, 'Missouri', 'MO'),
(82, 186, 'Montana', 'MT'),
(83, 186, 'Nebraska', 'NE'),
(84, 186, 'Nevada', 'NV'),
(85, 186, 'New Hampshire', 'NH'),
(86, 186, 'New Jersey', 'NJ'),
(87, 186, 'New Mexico', 'NM'),
(88, 186, 'New York', 'NY'),
(89, 186, 'North Carolina', 'NC'),
(90, 186, 'North Dakota', 'ND'),
(91, 186, 'Ohio', 'OH'),
(92, 186, 'Oklahoma', 'OK'),
(93, 186, 'Oregon', 'OR'),
(94, 186, 'Pennsylvania', 'PA'),
(95, 186, 'Rhode Island', 'RI'),
(96, 186, 'South Carolina', 'SC'),
(97, 186, 'South Dakota', 'SD'),
(98, 186, 'Tennessee', 'TN'),
(99, 186, 'Texas', 'TX'),
(100, 186, 'Utah', 'UT'),
(101, 186, 'Vermont', 'VT'),
(102, 186, 'Virginia', 'VA'),
(103, 186, 'Washington', 'WA'),
(104, 186, 'West Virginia', 'WV'),
(105, 186, 'Wisconsin', 'WI'),
(106, 186, 'Wyoming', 'WY'),
(107, 185, 'England', 'ENG'),
(108, 185, 'Scotland', 'SCO'),
(109, 185, 'Wales', 'WAL'),
(110, 185, 'Northern Ireland', 'NIR'),
(111, 185, 'London', 'LDN'),
(112, 185, 'Midlands', 'MDL'),
(113, 185, 'North West', 'NWR'),
(114, 185, 'Yorkshire and the Humber', 'YOR'),
(115, 1, 'Badakhshan', 'BAD'),
(116, 1, 'Badghis', 'BAG'),
(117, 1, 'Baghlan', 'BAL'),
(118, 1, 'Balkh', 'BALK'),
(119, 1, 'Bamyan', 'BAM'),
(120, 1, 'Daykundi', 'DAY'),
(121, 1, 'Farah', 'FAR'),
(122, 1, 'Faryab', 'FYB'),
(123, 1, 'Ghazni', 'GHA'),
(124, 1, 'Ghor', 'GHO'),
(125, 1, 'Helmand', 'HEL'),
(126, 1, 'Herat', 'HER'),
(127, 1, 'Jowzjan', 'JOW'),
(128, 1, 'Kabul', 'KAB'),
(129, 1, 'Kandahar', 'KAN'),
(130, 1, 'Kapisa', 'KAP'),
(131, 1, 'Khost', 'KHO'),
(132, 1, 'Kunar', 'KUN'),
(133, 1, 'Kunduz', 'KDZ'),
(134, 1, 'Laghman', 'LAG'),
(135, 1, 'Logar', 'LOG'),
(136, 1, 'Nangarhar', 'NAN'),
(137, 1, 'Nimruz', 'NIM'),
(138, 1, 'Nuristan', 'NUR'),
(139, 1, 'Paktia', 'PIA'),
(140, 1, 'Paktika', 'PKA'),
(141, 1, 'Panjshir', 'PAN'),
(142, 1, 'Parwan', 'PAR'),
(143, 1, 'Samangan', 'SAM'),
(144, 1, 'Sar-e Pol', 'SAR'),
(145, 1, 'Takhar', 'TAK'),
(146, 1, 'Urozgan', 'URO'),
(147, 1, 'Zabul', 'ZAB'),
(148, 2, 'Berat', 'BR'),
(149, 2, 'Dibër', 'DI'),
(150, 2, 'Durrës', 'DU'),
(151, 2, 'Elbasan', 'EL'),
(152, 2, 'Fier', 'FR'),
(153, 2, 'Gjirokastër', 'GJ'),
(154, 2, 'Korçë', 'KO'),
(155, 2, 'Kukës', 'KU'),
(156, 2, 'Lezhë', 'LE'),
(157, 2, 'Shkodër', 'SH'),
(158, 2, 'Tiranë', 'TR'),
(159, 2, 'Vlorë', 'VL'),
(173, 3, 'Adrar', 'ADR'),
(174, 3, 'Chlef', 'CHL'),
(175, 3, 'Laghouat', 'LAG'),
(176, 3, 'Oum El Bouaghi', 'OEB'),
(177, 3, 'Batna', 'BAT'),
(178, 3, 'Béjaïa', 'BEJ'),
(179, 3, 'Biskra', 'BIS'),
(180, 3, 'Béchar', 'BEC'),
(181, 3, 'Blida', 'BLI'),
(182, 3, 'Bouira', 'BOU'),
(183, 3, 'Tamanrasset', 'TAM'),
(184, 3, 'Tébessa', 'TEB'),
(185, 3, 'Tlemcen', 'TLE'),
(186, 3, 'Tiaret', 'TIA'),
(187, 3, 'Tizi Ouzou', 'TIZ'),
(188, 3, 'Algiers', 'ALG'),
(189, 3, 'Djelfa', 'DJE'),
(190, 3, 'Jijel', 'JIJ'),
(191, 3, 'Sétif', 'SET'),
(192, 3, 'Saïda', 'SAI'),
(193, 3, 'Skikda', 'SKI'),
(194, 3, 'Sidi Bel Abbès', 'SBA'),
(195, 3, 'Annaba', 'ANN'),
(196, 3, 'Guelma', 'GUE'),
(197, 3, 'Constantine', 'CON'),
(198, 3, 'Médéa', 'MED'),
(199, 3, 'Mostaganem', 'MOS'),
(202, 3, 'M\'Sila', 'MSI'),
(203, 3, 'Mascara', 'MAS'),
(204, 3, 'Ouargla', 'OUA'),
(205, 3, 'Oran', 'ORA'),
(206, 3, 'El Bayadh', 'EBA'),
(207, 3, 'Illizi', 'ILI'),
(208, 3, 'Bordj Bou Arréridj', 'BOB'),
(209, 3, 'Boumerdès', 'BOU'),
(210, 3, 'El Tarf', 'ETA'),
(211, 3, 'Tindouf', 'TIN'),
(212, 3, 'Tissemsilt', 'TIS'),
(213, 3, 'El Oued', 'EOU'),
(214, 3, 'Khenchela', 'KHE'),
(215, 3, 'Souk Ahras', 'SAH'),
(216, 3, 'Tipaza', 'TIP'),
(217, 3, 'Mila', 'MIL'),
(218, 3, 'Aïn Defla', 'ADF'),
(219, 3, 'Naâma', 'NAA'),
(220, 3, 'Aïn Témouchent', 'ATE'),
(221, 3, 'Ghardaïa', 'GHA'),
(222, 3, 'Relizane', 'REL'),
(223, 4, 'Andorra la Vella', 'ALV'),
(224, 4, 'Canillo', 'CAN'),
(225, 4, 'Encamp', 'ENC'),
(226, 4, 'Escaldes-Engordany', 'ESE'),
(227, 4, 'La Massana', 'LAM'),
(228, 4, 'Ordino', 'ORD'),
(229, 4, 'Sant Julià de Lòria', 'SJO'),
(230, 5, 'Bengo', 'BGO'),
(231, 5, 'Benguela', 'BGU'),
(232, 5, 'Bié', 'BIE'),
(233, 5, 'Cabinda', 'CAB'),
(234, 5, 'Cunene', 'CNU'),
(235, 5, 'Huambo', 'HUA'),
(236, 5, 'Huíla', 'HUI'),
(237, 5, 'Kuando Kubango', 'KKN'),
(238, 5, 'Kwanza Norte', 'KNO'),
(239, 5, 'Kwanza Sul', 'KUS'),
(240, 5, 'Luanda', 'LUA'),
(241, 5, 'Lunda Norte', 'LNO'),
(242, 5, 'Lunda Sul', 'LSU'),
(243, 5, 'Malanje', 'MAL'),
(244, 5, 'Moxico', 'MOX'),
(245, 5, 'Namibe', 'NAM'),
(246, 5, 'Uíge', 'UIG'),
(247, 5, 'Zaire', 'ZAI'),
(248, 7, 'Buenos Aires', 'BA'),
(249, 7, 'Catamarca', 'CT'),
(250, 7, 'Chaco', 'CH'),
(251, 7, 'Chubut', 'CB'),
(252, 7, 'Córdoba', 'CO'),
(253, 7, 'Corrientes', 'CR'),
(254, 7, 'Entre Ríos', 'ER'),
(255, 7, 'Formosa', 'FO'),
(256, 7, 'Jujuy', 'JU'),
(257, 7, 'La Pampa', 'LP'),
(258, 7, 'La Rioja', 'LR'),
(259, 7, 'Mendoza', 'MZ'),
(260, 7, 'Misiones', 'MI'),
(261, 7, 'Neuquén', 'NQ'),
(262, 7, 'Río Negro', 'RN'),
(263, 7, 'Salta', 'SA'),
(264, 7, 'San Juan', 'SJ'),
(265, 7, 'San Luis', 'SL'),
(266, 7, 'Santa Cruz', 'SC'),
(267, 7, 'Santa Fe', 'SF'),
(268, 7, 'Santiago del Estero', 'SE'),
(269, 7, 'Tierra del Fuego', 'TF'),
(270, 7, 'Tucumán', 'TU'),
(271, 32, 'Alberta', 'AB'),
(272, 32, 'British Columbia', 'BC'),
(273, 32, 'Manitoba', 'MB'),
(274, 32, 'New Brunswick', 'NB'),
(275, 32, 'Newfoundland and Labrador', 'NL'),
(276, 32, 'Northwest Territories', 'NT'),
(277, 32, 'Nova Scotia', 'NS'),
(278, 32, 'Nunavut', 'NU'),
(279, 32, 'Ontario', 'ON'),
(280, 32, 'Prince Edward Island', 'PE'),
(281, 32, 'Quebec', 'QC'),
(282, 32, 'Saskatchewan', 'SK'),
(283, 32, 'Yukon', 'YT'),
(286, 125, 'Northland ', 'NTL'),
(287, 125, 'Auckland ', 'AKL'),
(288, 125, 'Waikato ', 'WKT'),
(289, 125, 'Bay of Plenty', 'BOP'),
(290, 125, 'Gisborne ', 'GIS'),
(291, 125, 'Hawkes Bay', 'HKB'),
(292, 125, 'Taranaki', 'TKA'),
(293, 125, 'Manawatu-Whanganui', 'MWT'),
(294, 125, 'Wellington', 'WGN'),
(295, 125, 'Tasman ', 'TAS'),
(296, 125, 'Nelson', 'NSN'),
(297, 125, 'Marlborough', 'MBH'),
(298, 125, 'West Coast', 'WTC'),
(299, 125, 'Canterbury ', 'CAN'),
(300, 125, 'Otago', 'OTA'),
(301, 125, 'Southland ', 'STL'),
(302, 125, 'Chatham Islands', 'CHT'),
(303, 140, 'Lower Silesian Voivodeship', 'DS'),
(304, 140, 'Kuyavian-Pomeranian Voivodeship', 'KP'),
(305, 140, 'Lubusz Voivodeship', 'LU'),
(306, 140, 'Łódź Voivodeship', 'LD'),
(307, 140, 'Lesser Poland Voivodeship', 'MP'),
(308, 140, 'Masovian Voivodeship', 'MZ'),
(309, 140, 'Opole Voivodeship', 'OP'),
(310, 140, 'Subcarpathian Voivodeship', 'PK'),
(311, 140, 'Podlaskie Voivodeship', 'PD'),
(312, 140, 'Pomeranian Voivodeship', 'PM'),
(313, 140, 'Silesian Voivodeship', 'SL'),
(314, 140, 'Świętokrzyskie Voivodeship', 'SK'),
(315, 140, 'Warmian-Masurian Voivodeship', 'WM'),
(316, 140, 'Greater Poland Voivodeship', 'WP'),
(317, 140, 'West Pomeranian Voivodeship', 'ZP'),
(318, 140, 'Lublin Voivodeship', 'LB'),
(319, 60, 'Auvergne-Rhône-Alpes', 'ARA'),
(320, 60, 'Bourgogne-Franche-Comté', 'BFC'),
(321, 60, 'Brittany', 'BRE'),
(322, 60, 'Centre-Val de Loire', 'CVL'),
(323, 60, 'Corsica', 'COR'),
(324, 60, 'Grand Est', 'GES'),
(325, 60, 'Hauts-de-France', 'HDF'),
(326, 60, 'Île-de-France', 'IDF'),
(327, 60, 'Normandy', 'NOR'),
(328, 60, 'Nouvelle-Aquitaine', 'NAQ'),
(329, 60, 'Occitanie', 'OCC'),
(330, 60, 'Pays de la Loire', 'PDL'),
(331, 60, 'Provence-Alpes-Côte d\'Azur', 'PAC'),
(332, 60, 'French Guiana', 'GUF'),
(333, 60, 'Guadeloupe', 'GLP'),
(334, 60, 'Martinique', 'MTQ'),
(335, 60, 'Mayotte', 'MYT'),
(336, 60, 'Réunion', 'REU'),
(337, 179, 'Marmara', 'MAR'),
(338, 179, 'Aegean', 'AEG'),
(339, 179, 'Black Sea', 'BLK'),
(340, 179, 'Central Anatolia', 'CEN'),
(341, 179, 'Eastern Anatolia', 'EAS'),
(342, 179, 'Southeastern Anatolia', 'SEA'),
(343, 179, 'Mediterranean', 'MED'),
(344, 169, 'Aargau', 'AG'),
(345, 169, 'Appenzell Ausserrhoden', 'AR'),
(346, 169, 'Appenzell Innerrhoden', 'AI'),
(347, 169, 'Basel-Landschaft', 'BL'),
(348, 169, 'Basel-Stadt', 'BS'),
(349, 169, 'Bern', 'BE'),
(350, 169, 'Fribourg', 'FR'),
(351, 169, 'Geneva', 'GE'),
(352, 169, 'Glarus', 'GL'),
(353, 169, 'Graubünden', 'GR'),
(354, 169, 'Jura', 'JU'),
(355, 169, 'Lucerne', 'LU'),
(356, 169, 'Neuchâtel', 'NE'),
(357, 169, 'Nidwalden', 'NW'),
(358, 169, 'Obwalden', 'OW'),
(359, 169, 'Schaffhausen', 'SH'),
(360, 169, 'Schwyz', 'SZ'),
(361, 169, 'Solothurn', 'SO'),
(362, 169, 'St. Gallen', 'SG'),
(363, 169, 'Thurgau', 'TG'),
(364, 169, 'Ticino', 'TI'),
(365, 169, 'Uri', 'UR'),
(366, 169, 'Valais', 'VS'),
(367, 169, 'Vaud', 'VD'),
(368, 169, 'Zug', 'ZG'),
(369, 169, 'Zurich', 'ZH'),
(370, 82, 'Abruzzo', 'AB'),
(371, 82, 'Basilicata', 'BA'),
(372, 82, 'Calabria', 'CA'),
(373, 82, 'Campania', 'CM'),
(374, 82, 'Emilia-Romagna', 'ER'),
(375, 82, 'Friuli-Venezia Giulia', 'FVG'),
(376, 82, 'Lazio', 'LZ'),
(377, 82, 'Liguria', 'LG'),
(378, 82, 'Lombardy', 'LM'),
(379, 82, 'Marche', 'MC'),
(380, 82, 'Molise', 'ML'),
(381, 82, 'Piedmont', 'PI'),
(382, 82, 'Apulia', 'PU'),
(383, 82, 'Sardinia', 'SA'),
(384, 82, 'Sicily', 'SI'),
(385, 82, 'Trentino-Alto Adige/Südtirol', 'TR'),
(386, 82, 'Tuscany', 'TU'),
(387, 82, 'Umbria', 'UM'),
(388, 82, 'Aosta Valley', 'AO'),
(389, 82, 'Veneto', 'VE'),
(390, 101, 'Vilnius County', 'VL'),
(391, 101, 'Kaunas County', 'KA'),
(392, 101, 'Klaipėda County', 'KL'),
(393, 101, 'Panevėžys County', 'PA'),
(394, 101, 'Šiauliai County', 'SA'),
(395, 101, 'Alytus County', 'AL'),
(396, 101, 'Tauragė County', 'TA'),
(397, 101, 'Telšiai County', 'TE'),
(398, 101, 'Utena County', 'UT'),
(399, 101, 'Marijampolė County', 'MA'),
(400, 102, 'Luxembourg District', 'LUX'),
(401, 102, 'Diekirch District', 'DIE'),
(402, 102, 'Grevenmacher District', 'GRE'),
(403, 108, 'Northern Region', 'NR'),
(404, 108, 'Gozo Region', 'GR'),
(405, 108, 'Port Region', 'PR'),
(406, 108, 'Southern Region', 'SR'),
(407, 108, 'Eastern Region', 'ER'),
(408, 108, 'Western Region', 'WR'),
(409, 92, 'Al Asimah Governorate', 'AA'),
(410, 92, 'Hawalli Governorate', 'HG'),
(411, 92, 'Farwaniya Governorate', 'FG'),
(412, 92, 'Al Ahmadi Governorate', 'AG'),
(413, 92, 'Mubarak Al-Kabeer Governorate', 'MKG'),
(414, 92, 'Jahra Governorate', 'JG'),
(415, 76, 'Andaman and Nicobar Islands', 'AN'),
(416, 76, 'Chandigarh', 'CH'),
(417, 76, 'Dadra and Nagar Haveli and Daman and Diu', 'DN'),
(418, 76, 'Lakshadweep', 'LD'),
(419, 76, 'Delhi', 'DL'),
(420, 76, 'Puducherry', 'PY'),
(421, 76, 'Ladakh', 'LA'),
(422, 77, 'Aceh', 'AC'),
(423, 77, 'North Sumatra', 'SU'),
(424, 77, 'West Sumatra', 'SB'),
(425, 77, 'Riau', 'RI'),
(426, 77, 'Riau Islands', 'KR'),
(427, 77, 'Jambi', 'JA'),
(428, 77, 'Bangka Belitung Islands', 'BB'),
(429, 77, 'South Sumatra', 'SS'),
(430, 77, 'Bengkulu', 'BE'),
(431, 77, 'Lampung', 'LA'),
(432, 77, 'Banten', 'BT'),
(433, 77, 'Jakarta Special Capital Region', 'JK'),
(434, 77, 'West Java', 'JB'),
(435, 77, 'Central Java', 'JT'),
(436, 77, 'Yogyakarta Special Region', 'YO'),
(437, 77, 'East Java', 'JT'),
(438, 77, 'Bali', 'BA'),
(439, 77, 'West Nusa Tenggara', 'NTB'),
(440, 77, 'East Nusa Tenggara', 'NTT'),
(441, 77, 'West Kalimantan', 'KB'),
(442, 77, 'Central Kalimantan', 'KT'),
(443, 77, 'South Kalimantan', 'KS'),
(444, 77, 'East Kalimantan', 'KI'),
(445, 77, 'North Kalimantan', 'KU'),
(446, 77, 'North Sulawesi', 'SU'),
(447, 77, 'Gorontalo', 'GO'),
(448, 77, 'Central Sulawesi', 'ST'),
(449, 77, 'West Sulawesi', 'SB'),
(450, 77, 'South Sulawesi', 'SS'),
(451, 77, 'Southeast Sulawesi', 'ST'),
(452, 77, 'North Maluku', 'MU'),
(453, 77, 'Maluku', 'MA'),
(454, 77, 'West Papua', 'PB'),
(455, 77, 'Papua', 'PA'),
(456, 105, 'Johor', 'JHR'),
(457, 105, 'Kedah', 'KDH'),
(458, 105, 'Kelantan', 'KTN'),
(459, 105, 'Melaka', 'MLK'),
(460, 105, 'Negeri Sembilan', 'NSN'),
(461, 105, 'Pahang', 'PHG'),
(462, 105, 'Perak', 'PRK'),
(463, 105, 'Perlis', 'PLS'),
(464, 105, 'Pulau Pinang', 'PNG'),
(465, 105, 'Sabah', 'SBH'),
(466, 105, 'Sarawak', 'SRW'),
(467, 105, 'Selangor', 'SGR'),
(468, 105, 'Terengganu', 'TRG'),
(469, 105, 'Kuala Lumpur', 'KL'),
(470, 105, 'Putrajaya', 'PJY'),
(471, 105, 'Labuan', 'LBN'),
(472, 157, 'Central Region', 'CR'),
(473, 157, 'North Region', 'NR'),
(474, 157, 'North-East Region', 'NE'),
(475, 157, 'East Region', 'ER'),
(476, 157, 'West Region', 'WR'),
(680, 174, 'Bangkok (Special Administrative Region)', 'BKK'),
(681, 174, 'Samut Prakan', 'SPK'),
(682, 174, 'Nonthaburi', 'NTB'),
(683, 174, 'Pathum Thani', 'PTN'),
(684, 174, 'Samut Sakhon', 'SKN'),
(685, 174, 'Nakhon Pathom', 'NKP'),
(686, 174, 'Phra Nakhon Si Ayutthaya', 'PYA'),
(687, 174, 'Ang Thong', 'ATG'),
(688, 174, 'Lopburi', 'LRI'),
(689, 174, 'Sing Buri', 'SBR'),
(690, 174, 'Chai Nat', 'CNT'),
(691, 174, 'Saraburi', 'SRI'),
(692, 174, 'Chon Buri', 'CBI'),
(693, 174, 'Rayong', 'RYG'),
(694, 174, 'Chanthaburi', 'CTB'),
(695, 174, 'Trat', 'TRT'),
(696, 174, 'Chachoengsao', 'CCS'),
(697, 174, 'Prachin Buri', 'PCB'),
(698, 174, 'Nakhon Nayok', 'NYK'),
(699, 174, 'Sa Kaeo', 'SKW'),
(700, 174, 'Nakhon Ratchasima', 'NMA'),
(701, 174, 'Buri Ram', 'BRM'),
(702, 174, 'Surin', 'SRN'),
(703, 174, 'Si Sa Ket', 'SST'),
(704, 174, 'Ubon Ratchathani', 'UBT'),
(705, 174, 'Yasothon', 'YSN'),
(706, 174, 'Chaiyaphum', 'CYP'),
(707, 174, 'Amnat Charoen', 'AMN'),
(708, 174, 'Bueng Kan', 'BKN'),
(709, 174, 'Nong Bua Lamphu', 'NBL'),
(710, 174, 'Khon Kaen', 'KKN'),
(711, 174, 'Udon Thani', 'UDN'),
(712, 174, 'Loei', 'LOI'),
(713, 174, 'Nong Khai', 'NKI'),
(714, 174, 'Maha Sarakham', 'MSK'),
(715, 174, 'Roi Et', 'RET'),
(716, 174, 'Kalasin', 'KSN'),
(717, 174, 'Sakon Nakhon', 'SKN'),
(718, 174, 'Nakhon Phanom', 'NPM'),
(719, 174, 'Mukdahan', 'MDH'),
(720, 174, 'Chiang Mai', 'CNX'),
(721, 174, 'Lamphun', 'LPN'),
(722, 174, 'Lampang', 'LPG'),
(723, 174, 'Uttaradit', 'UTD'),
(724, 174, 'Phitsanulok', 'PSK'),
(725, 174, 'Sukhothai', 'STI'),
(726, 174, 'Phichit', 'PCT'),
(727, 174, 'Phetchabun', 'PCB'),
(728, 174, 'Ratchaburi', 'RBR'),
(729, 174, 'Kanchanaburi', 'KRI'),
(730, 174, 'Suphan Buri', 'SPB'),
(731, 174, 'Samut Songkhram', 'SKM'),
(732, 174, 'Phetchaburi', 'PBI'),
(733, 174, 'Prachuap Khiri Khan', 'PKK'),
(734, 174, 'Nakhon Si Thammarat', 'NRT'),
(735, 174, 'Krabi', 'KBI'),
(736, 174, 'Phang Nga', 'PNA'),
(737, 174, 'Phuket', 'PKT'),
(738, 174, 'Surat Thani', 'SNI'),
(739, 174, 'Ranong', 'RNG'),
(740, 174, 'Chumphon', 'CPN'),
(741, 174, 'Songkhla', 'SKI'),
(742, 174, 'Satun', 'STN'),
(743, 174, 'Yala', 'YLA'),
(744, 174, 'Narathiwat', 'NTW'),
(745, 174, 'Pattani', 'PNI'),
(746, 116, 'Arkhangai', 'AR'),
(747, 116, 'Bayan-Ölgii', 'BO'),
(748, 116, 'Bayankhongor', 'BK'),
(749, 116, 'Bulgan', 'BU'),
(750, 116, 'Darkhan-Uul', 'DU'),
(751, 116, 'Dornod', 'DO'),
(752, 116, 'Dornogovi', 'DG'),
(753, 116, 'Dundgovi', 'DG'),
(754, 116, 'Govi-Altai', 'GA'),
(755, 116, 'Govisümber', 'GS'),
(756, 116, 'Khentii', 'KE'),
(757, 116, 'Khovd', 'KO'),
(758, 116, 'Khövsgöl', 'KV'),
(759, 116, 'Ömnögovi', 'OG'),
(760, 116, 'Orkhon', 'OR'),
(761, 116, 'Övörkhangai', 'OK'),
(762, 116, 'Selenge', 'SE'),
(763, 116, 'Sükhbaatar', 'SB'),
(764, 116, 'Töv', 'TV'),
(765, 116, 'Uvs', 'UV'),
(766, 116, 'Zavkhan', 'ZA'),
(767, 139, 'Ilocos Region', 'Regio'),
(768, 139, 'Cagayan Valley', 'Regio'),
(769, 139, 'Central Luzon', 'Regio'),
(770, 139, 'CALABARZON', 'Regio'),
(771, 139, 'MIMAROPA', 'Regio'),
(772, 139, 'Bicol Region', 'Regio'),
(773, 139, 'Western Visayas', 'Regio'),
(774, 139, 'Central Visayas', 'Regio'),
(775, 139, 'Eastern Visayas', 'Regio'),
(776, 139, 'Zamboanga Peninsula', 'Regio'),
(777, 139, 'Northern Mindanao', 'Regio'),
(778, 139, 'Davao Region', 'Regio'),
(779, 139, 'SOCCSKSARGEN', 'Regio'),
(780, 139, 'Caraga', 'Regio'),
(781, 139, 'Bangsamoro Autonomous Region in Muslim Mindanao', 'BARMM'),
(782, 139, 'Cordillera Administrative Region', 'CAR'),
(783, 139, 'National Capital Region', 'NCR'),
(784, 35, 'Arica and Parinacota', 'AP'),
(785, 35, 'Tarapacá', 'TA'),
(786, 35, 'Antofagasta', 'AN'),
(787, 35, 'Atacama', 'AT'),
(788, 35, 'Coquimbo', 'CO'),
(789, 35, 'Valparaíso', 'VA'),
(790, 35, 'Santiago Metropolitan (Región Metropolitana)', 'RM'),
(791, 35, 'Libertador General Bernardo OHiggins', 'LI'),
(792, 35, 'Maule', 'MA'),
(793, 35, 'Ñuble', 'NU'),
(794, 35, 'Biobío', 'BI'),
(795, 35, 'La Araucanía', 'AR'),
(796, 35, 'Los Ríos', 'LR'),
(797, 35, 'Los Lagos', 'LL'),
(798, 35, 'Aysén', 'AY'),
(799, 35, 'Magallanes and Chilean Antarctica', 'MG'),
(800, 112, 'Aguascalientes', 'AGS'),
(801, 112, 'Baja California', 'BC'),
(802, 112, 'Baja California Sur', 'BCS'),
(803, 112, 'Campeche', 'CAMP'),
(804, 112, 'Chiapas', 'CHIS'),
(805, 112, 'Chihuahua', 'CHIH'),
(806, 112, 'Coahuila', 'COAH'),
(807, 112, 'Colima', 'COL'),
(808, 112, 'Durango', 'DGO'),
(809, 112, 'Guanajuato', 'GTO'),
(810, 112, 'Guerrero', 'GRO'),
(811, 112, 'Hidalgo', 'HGO'),
(812, 112, 'Jalisco', 'JAL'),
(813, 112, 'México (Estado de México)', 'MEX'),
(814, 112, 'Michoacán', 'MICH'),
(815, 112, 'Morelos', 'MOR'),
(816, 112, 'Nayarit', 'NAY'),
(817, 112, 'Nuevo León', 'NL'),
(818, 112, 'Oaxaca', 'OAX'),
(819, 112, 'Puebla', 'PUE'),
(820, 112, 'Querétaro', 'QRO'),
(821, 112, 'Quintana Roo', 'QROO'),
(822, 112, 'San Luis Potosí', 'SLP'),
(823, 112, 'Sinaloa', 'SIN'),
(824, 112, 'Sonora', 'SON'),
(825, 112, 'Tabasco', 'TAB'),
(826, 112, 'Tamaulipas', 'TAMPS'),
(827, 112, 'Tlaxcala', 'TLAX'),
(828, 112, 'Veracruz', 'VER'),
(829, 112, 'Yucatán', 'YUC'),
(830, 112, 'Zacatecas', 'ZAC'),
(831, 112, 'Ciudad de México (Mexico City)', 'CDMX'),
(832, 128, 'Abia', 'AB'),
(833, 128, 'Adamawa', 'AD'),
(834, 128, 'Akwa Ibom', 'AK'),
(835, 128, 'Anambra', 'AN'),
(836, 128, 'Bauchi', 'BA'),
(837, 128, 'Bayelsa', 'BY'),
(838, 128, 'Benue', 'BE'),
(839, 128, 'Borno', 'BO'),
(840, 128, 'Cross River', 'CR'),
(841, 128, 'Delta', 'DE'),
(842, 128, 'Ebonyi', 'EB'),
(843, 128, 'Edo', 'ED'),
(844, 128, 'Ekiti', 'EK'),
(845, 128, 'Enugu', 'EN'),
(846, 128, 'Gombe', 'GO'),
(847, 128, 'Imo', 'IM'),
(848, 128, 'Jigawa', 'JI'),
(849, 128, 'Kaduna', 'KD'),
(850, 128, 'Kano', 'KN'),
(851, 128, 'Katsina', 'KT'),
(852, 128, 'Kebbi', 'KB'),
(853, 128, 'Kogi', 'KO'),
(854, 128, 'Kwara', 'KW'),
(855, 128, 'Lagos', 'LA'),
(856, 128, 'Nasarawa', 'NA'),
(857, 128, 'Niger', 'NI'),
(858, 128, 'Ogun', 'OG'),
(859, 128, 'Ondo', 'ON'),
(860, 128, 'Osun', 'OS'),
(861, 128, 'Oyo', 'OY'),
(862, 128, 'Plateau', 'PL'),
(863, 128, 'Rivers', 'RI'),
(864, 128, 'Sokoto', 'SO'),
(865, 128, 'Taraba', 'TA'),
(866, 128, 'Yobe', 'YO'),
(867, 128, 'Zamfara', 'ZA');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_status`
--

CREATE TABLE `tbl_status` (
  `statusId` int(11) NOT NULL,
  `status` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_status`
--

INSERT INTO `tbl_status` (`statusId`, `status`) VALUES
(1, 'ACTIVE'),
(4, 'DELETED'),
(3, 'DISABLED'),
(2, 'INACTIVE');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_login_audit`
--

CREATE TABLE `tbl_user_login_audit` (
  `userLoginAuditId` int(11) NOT NULL,
  `userProfileId` int(11) NOT NULL,
  `action` varchar(50) NOT NULL,
  `actionDateTime` datetime NOT NULL DEFAULT current_timestamp(),
  `deviceId` varchar(50) NOT NULL,
  `comments` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_user_login_audit`
--

INSERT INTO `tbl_user_login_audit` (`userLoginAuditId`, `userProfileId`, `action`, `actionDateTime`, `deviceId`, `comments`) VALUES
(1, 56, 'Login', '2023-10-03 06:48:41', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(2, 56, 'Login', '2023-10-03 06:51:14', '59.182.142.202', 'User Habeeb A logged-in successfully'),
(3, 57, 'Login', '2023-10-03 07:01:42', '68.178.155.83', 'User Alen Cooper logged-in successfully'),
(4, 58, 'Login', '2023-10-03 07:18:47', '68.178.155.83', 'User John Doe logged-in successfully'),
(5, 56, 'Login', '2023-10-03 07:20:02', '185.218.127.188', 'User Habeeb A logged-in successfully'),
(6, 56, 'Login', '2023-10-03 07:22:04', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(7, 57, 'Login', '2023-10-03 07:22:39', '68.178.155.83', 'User Alen Cooper logged-in successfully'),
(8, 56, 'Login', '2023-10-03 07:24:52', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(9, 56, 'Login', '2023-10-03 07:28:28', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(10, 56, 'Login', '2023-10-03 08:10:58', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(11, 56, 'Login', '2023-10-03 08:11:32', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(12, 56, 'Login', '2023-10-03 08:59:29', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(13, 56, 'Login', '2023-10-03 09:02:27', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(14, 56, 'Login', '2023-10-03 09:14:17', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(15, 56, 'Login', '2023-10-03 09:24:20', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(16, 56, 'Login', '2023-10-03 09:50:27', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(17, 56, 'Login', '2023-10-03 09:51:22', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(18, 56, 'Login', '2023-10-03 09:52:06', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(19, 58, 'Login', '2023-10-03 09:56:04', '103.151.189.106', 'User John Doe logged-in successfully'),
(20, 56, 'Login', '2023-10-03 10:06:22', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(21, 58, 'Login', '2023-10-03 10:09:18', '103.151.189.106', 'User John Doe logged-in successfully'),
(22, 56, 'Login', '2023-10-03 10:10:05', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(23, 57, 'Login', '2023-10-03 10:11:42', '103.151.189.106', 'User Alen Cooper logged-in successfully'),
(24, 56, 'Login', '2023-10-03 10:15:02', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(25, 56, 'Login', '2023-10-03 10:52:30', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(26, 57, 'Login', '2023-10-03 10:52:48', '103.151.189.106', 'User Alen Cooper logged-in successfully'),
(27, 56, 'Login', '2023-10-03 11:01:43', '103.151.189.106', 'User Habeeb A logged-in successfully'),
(28, 57, 'Login', '2023-10-03 13:20:29', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(29, 56, 'Login', '2023-10-03 14:17:09', '58.178.56.87', 'User Habeeb A logged-in successfully'),
(30, 57, 'Login', '2023-10-03 14:21:39', '58.178.56.87', 'User Alen Cooper logged-in successfully'),
(31, 56, 'Login', '2023-10-03 14:23:44', '58.178.56.87', 'User Habeeb A logged-in successfully'),
(32, 56, 'Login', '2023-10-03 14:25:20', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(33, 56, 'Login', '2023-10-03 14:51:31', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(34, 59, 'Login', '2023-10-03 15:40:27', '68.178.155.83', 'User Daniel mcgril logged-in successfully'),
(35, 56, 'Login', '2023-10-03 15:43:25', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(36, 58, 'Login', '2023-10-03 15:44:32', '68.178.155.83', 'User John Doe logged-in successfully'),
(37, 56, 'Login', '2023-10-03 22:54:06', '58.178.56.87', 'User Habeeb A logged-in successfully'),
(38, 56, 'Login', '2023-10-03 23:33:48', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(39, 57, 'Login', '2023-10-04 02:58:20', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(40, 56, 'Login', '2023-10-04 03:01:36', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(41, 56, 'Login', '2023-10-04 03:47:41', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(42, 57, 'Login', '2023-10-04 03:53:50', '68.178.155.83', 'User Alen Cooper logged-in successfully'),
(43, 59, 'Login', '2023-10-04 04:03:17', '68.178.155.83', 'User Daniel mcgril logged-in successfully'),
(44, 56, 'Login', '2023-10-04 04:40:29', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(45, 57, 'Login', '2023-10-04 04:40:43', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(46, 57, 'Login', '2023-10-04 04:51:46', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(47, 56, 'Login', '2023-10-04 05:54:59', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(48, 57, 'Login', '2023-10-04 05:56:06', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(49, 56, 'Login', '2023-10-04 05:58:12', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(50, 57, 'Login', '2023-10-04 07:03:05', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(51, 58, 'Login', '2023-10-04 07:03:18', '103.151.189.120', 'User John Doe logged-in successfully'),
(52, 59, 'Login', '2023-10-04 07:29:57', '68.178.155.83', 'User Daniel mcgril logged-in successfully'),
(53, 56, 'Login', '2023-10-04 07:32:33', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(54, 59, 'Login', '2023-10-04 07:33:17', '68.178.155.83', 'User Daniel mcgril logged-in successfully'),
(55, 58, 'Login', '2023-10-04 07:34:16', '68.178.155.83', 'User John Doe logged-in successfully'),
(56, 59, 'Login', '2023-10-04 07:35:44', '68.178.155.83', 'User Daniel mcgril logged-in successfully'),
(57, 56, 'Login', '2023-10-04 07:57:47', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(58, 57, 'Login', '2023-10-04 07:58:07', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(59, 56, 'Login', '2023-10-04 08:01:01', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(60, 58, 'Login', '2023-10-04 08:08:02', '103.151.189.120', 'User John Doe logged-in successfully'),
(61, 57, 'Login', '2023-10-04 08:10:27', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(62, 56, 'Login', '2023-10-04 08:12:16', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(63, 56, 'Login', '2023-10-04 08:23:10', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(64, 56, 'Login', '2023-10-04 08:35:57', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(65, 56, 'Login', '2023-10-04 09:06:25', '181.214.151.40', 'User Habeeb A logged-in successfully'),
(66, 56, 'Login', '2023-10-04 09:10:17', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(67, 59, 'Login', '2023-10-04 09:16:38', '68.178.155.83', 'User Daniel mcgril logged-in successfully'),
(68, 56, 'Login', '2023-10-04 09:17:01', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(69, 59, 'Login', '2023-10-04 09:17:37', '68.178.155.83', 'User Daniel mcgril logged-in successfully'),
(70, 56, 'Login', '2023-10-04 09:18:56', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(71, 59, 'Login', '2023-10-04 09:21:10', '68.178.155.83', 'User Daniel mcgril logged-in successfully'),
(72, 56, 'Login', '2023-10-04 09:24:33', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(73, 56, 'Login', '2023-10-04 09:29:38', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(74, 56, 'Login', '2023-10-04 09:34:26', '181.214.151.40', 'User Habeeb A logged-in successfully'),
(75, 56, 'Login', '2023-10-04 09:36:41', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(76, 56, 'Login', '2023-10-04 10:10:48', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(77, 56, 'Login', '2023-10-04 10:38:29', '181.214.151.40', 'User Habeeb A logged-in successfully'),
(78, 58, 'Login', '2023-10-04 11:09:15', '103.151.189.120', 'User John Doe logged-in successfully'),
(79, 56, 'Login', '2023-10-04 11:35:23', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(80, 63, 'Login', '2023-10-04 12:32:58', '68.178.155.83', 'User Abshar Moorkath logged-in successfully'),
(81, 56, 'Login', '2023-10-04 12:33:21', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(82, 56, 'Login', '2023-10-04 12:35:30', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(83, 56, 'Login', '2023-10-04 12:35:59', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(84, 67, 'Login', '2023-10-04 12:41:39', '68.178.155.83', 'User Aman MOORKATH logged-in successfully'),
(85, 56, 'Login', '2023-10-04 12:42:05', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(86, 67, 'Login', '2023-10-04 12:43:21', '68.178.155.83', 'User Aman MOORKATH logged-in successfully'),
(87, 67, 'Login', '2023-10-04 12:44:22', '68.178.155.83', 'User Aman MOORKATH logged-in successfully'),
(88, 56, 'Login', '2023-10-04 12:44:46', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(89, 67, 'Login', '2023-10-04 12:45:59', '68.178.155.83', 'User Aman MOORKATH logged-in successfully'),
(90, 56, 'Login', '2023-10-04 12:46:39', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(91, 56, 'Login', '2023-10-04 12:48:35', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(92, 67, 'Login', '2023-10-04 12:52:50', '120.18.117.87', 'User Aman MOORKATH logged-in successfully'),
(93, 67, 'Login', '2023-10-04 13:15:18', '58.178.56.87', 'User Aman MOORKATH logged-in successfully'),
(94, 56, 'Login', '2023-10-04 13:16:00', '58.178.56.87', 'User Habeeb A logged-in successfully'),
(95, 56, 'Login', '2023-10-05 00:34:09', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(96, 56, 'Login', '2023-10-05 04:03:19', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(97, 56, 'Login', '2023-10-05 04:25:45', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(98, 57, 'Login', '2023-10-05 04:26:50', '68.178.155.83', 'User Alen Cooper logged-in successfully'),
(99, 56, 'Login', '2023-10-05 04:34:57', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(100, 56, 'Login', '2023-10-05 04:36:37', '185.222.243.50', 'User Habeeb A logged-in successfully'),
(101, 56, 'Login', '2023-10-05 04:38:25', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(102, 57, 'Login', '2023-10-05 04:39:55', '68.178.155.83', 'User Alen Cooper logged-in successfully'),
(103, 56, 'Login', '2023-10-05 04:42:20', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(104, 56, 'Login', '2023-10-05 04:47:54', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(105, 56, 'Login', '2023-10-05 05:02:32', '185.222.243.50', 'User Habeeb A logged-in successfully'),
(106, 56, 'Login', '2023-10-05 05:08:03', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(107, 60, 'Login', '2023-10-05 05:09:27', '68.178.155.83', 'User Lane Kuphal imporsonated by Habeeb A successfully'),
(108, 56, 'Login', '2023-10-05 05:10:35', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(109, 56, 'Login', '2023-10-05 05:19:52', '68.178.155.83', 'User Habeeb A imporsonated by Habeeb A successfully'),
(110, 56, 'Login', '2023-10-05 05:20:36', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(111, 61, 'Login', '2023-10-05 05:21:44', '68.178.155.83', 'User Hannah Dooley imporsonated by Habeeb A successfully'),
(112, 56, 'Login', '2023-10-05 05:25:21', '185.222.243.50', 'User Habeeb A logged-in successfully'),
(113, 56, 'Login', '2023-10-05 06:31:51', '185.222.243.44', 'User Habeeb A logged-in successfully'),
(114, 56, 'Login', '2023-10-05 08:01:17', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(115, 56, 'Login', '2023-10-05 08:02:25', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(116, 56, 'Login', '2023-10-05 08:07:45', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(117, 57, 'Login', '2023-10-05 08:08:33', '68.178.155.83', 'User Alen Cooper imporsonated by Habeeb A successfully'),
(118, 56, 'Login', '2023-10-05 08:09:25', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(119, 58, 'Login', '2023-10-05 08:12:34', '68.178.155.83', 'User John Doe logged-in successfully'),
(120, 56, 'Login', '2023-10-05 08:14:06', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(121, 56, 'Login', '2023-10-05 08:27:15', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(122, 57, 'Login', '2023-10-05 08:35:04', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(123, 58, 'Login', '2023-10-05 09:06:55', '103.151.189.120', 'User John Doe logged-in successfully'),
(124, 56, 'Login', '2023-10-05 09:09:58', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(125, 58, 'Login', '2023-10-05 09:16:54', '103.151.189.120', 'User John Doe logged-in successfully'),
(126, 57, 'Login', '2023-10-05 09:18:21', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(127, 58, 'Login', '2023-10-05 09:21:09', '103.151.189.120', 'User John Doe logged-in successfully'),
(128, 56, 'Login', '2023-10-05 09:24:48', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(129, 56, 'Login', '2023-10-05 09:36:48', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(130, 57, 'Login', '2023-10-05 09:42:00', '103.151.189.120', 'User Alen Cooper logged-in successfully'),
(131, 56, 'Login', '2023-10-05 09:42:14', '103.151.189.120', 'User Habeeb A logged-in successfully'),
(132, 56, 'Login', '2023-10-05 09:49:32', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(133, 56, 'Login', '2023-10-05 09:50:13', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(134, 56, 'Login', '2023-10-05 10:33:37', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(135, 57, 'Login', '2023-10-05 10:35:24', '68.178.155.83', 'User Alen Cooper logged-in successfully'),
(136, 56, 'Login', '2023-10-05 10:43:05', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(137, 56, 'Login', '2023-10-05 10:51:42', '2403:4800:24dc:4301:28f0:82be:95da:7a1b', 'User Habeeb A logged-in successfully'),
(138, 56, 'Login', '2023-10-05 10:57:27', '103.176.184.60', 'User Habeeb A logged-in successfully'),
(139, 56, 'Login', '2023-10-05 11:16:52', '103.176.184.60', 'User Habeeb A logged-in successfully'),
(140, 58, 'Login', '2023-10-05 11:18:49', '103.176.184.60', 'User John Doe logged-in successfully'),
(141, 56, 'Login', '2023-10-05 11:27:45', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(142, 56, 'Login', '2023-10-05 11:28:34', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(143, 56, 'Login', '2023-10-05 13:24:33', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(144, 56, 'Login', '2023-10-05 13:30:12', '103.176.184.60', 'User Habeeb A logged-in successfully'),
(145, 56, 'Login', '2023-10-05 17:28:36', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(146, 56, 'Login', '2023-10-05 21:01:39', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(147, 56, 'Login', '2023-10-05 21:01:40', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(148, 56, 'Login', '2023-10-05 21:04:57', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(149, 56, 'Login', '2023-10-05 21:04:57', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(150, 56, 'Login', '2023-10-05 23:15:35', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(151, 57, 'Login', '2023-10-05 23:21:48', '68.178.155.83', 'User Alen Cooper logged-in successfully'),
(152, 56, 'Login', '2023-10-05 23:29:07', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(153, 56, 'Login', '2023-10-06 01:54:56', '103.147.208.167', 'User Habeeb A logged-in successfully'),
(154, 56, 'Login', '2023-10-06 02:03:03', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(155, 56, 'Login', '2023-10-06 03:21:05', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(156, 56, 'Login', '2023-10-06 03:21:32', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(157, 56, 'Login', '2023-10-06 03:26:44', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(158, 56, 'Login', '2023-10-06 03:27:32', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(159, 56, 'Login', '2023-10-06 03:27:39', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(160, 56, 'Login', '2023-10-06 03:30:05', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(161, 56, 'Login', '2023-10-06 03:45:22', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(162, 56, 'Login', '2023-10-06 04:14:01', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(163, 56, 'Login', '2023-10-06 04:26:02', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(164, 57, 'Login', '2023-10-06 05:02:48', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(165, 56, 'Login', '2023-10-06 05:14:45', '103.147.208.167', 'User Habeeb A logged-in successfully'),
(166, 56, 'Login', '2023-10-06 05:30:47', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(167, 66, 'Login', '2023-10-06 05:31:23', '2a02:4780:11::4f', 'User Brendan Rivas logged-in successfully'),
(168, 56, 'Login', '2023-10-06 05:40:44', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(169, 56, 'Login', '2023-10-06 05:41:09', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(170, 56, 'Login', '2023-10-06 05:42:42', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(171, 56, 'Login', '2023-10-06 05:44:24', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(172, 56, 'Login', '2023-10-06 05:45:26', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(173, 58, 'Login', '2023-10-06 05:50:17', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(174, 58, 'Login', '2023-10-06 05:50:59', '68.178.155.83', 'User John Doe logged-in successfully'),
(175, 56, 'Login', '2023-10-06 05:56:21', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(176, 57, 'Login', '2023-10-06 06:00:27', '103.181.40.52', 'User Alen Cooper logged-in successfully'),
(177, 58, 'Login', '2023-10-06 06:06:55', '68.178.155.83', 'User John Doe logged-in successfully'),
(178, 58, 'Login', '2023-10-06 06:21:06', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(179, 57, 'Login', '2023-10-06 06:23:46', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(180, 56, 'Login', '2023-10-06 06:24:52', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(181, 60, 'Login', '2023-10-06 06:25:00', '2a02:4780:11::4f', 'User Lane Kuphal imporsonated by Habeeb A successfully'),
(182, 60, 'Login', '2023-10-06 06:27:44', '103.181.40.52', 'User Lane Kuphal imporsonated by Habeeb A successfully'),
(183, 56, 'Login', '2023-10-06 06:28:00', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(184, 56, 'Login', '2023-10-06 06:29:04', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(185, 57, 'Login', '2023-10-06 06:32:08', '103.181.40.52', 'User Alen Cooper logged-in successfully'),
(186, 56, 'Login', '2023-10-06 06:34:02', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(187, 56, 'Login', '2023-10-06 06:36:55', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(188, 56, 'Login', '2023-10-06 07:03:23', '86.48.8.88', 'User Habeeb A logged-in successfully'),
(189, 57, 'Login', '2023-10-06 07:04:20', '86.48.8.88', 'User Alen Cooper logged-in successfully'),
(190, 57, 'Login', '2023-10-06 07:10:43', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(191, 56, 'Login', '2023-10-06 07:32:40', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(192, 70, 'Login', '2023-10-06 07:34:32', '2a02:4780:11::4f', 'User Sarina Ortiz logged-in successfully'),
(193, 57, 'Login', '2023-10-06 07:36:10', '86.48.8.88', 'User Alen Cooper logged-in successfully'),
(194, 57, 'Login', '2023-10-06 07:41:05', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(195, 57, 'Login', '2023-10-06 07:41:59', '86.48.8.88', 'User Alen Cooper logged-in successfully'),
(196, 70, 'Login', '2023-10-06 07:42:08', '86.48.8.88', 'User Sarina Ortiz logged-in successfully'),
(197, 70, 'Login', '2023-10-06 07:47:38', '2a02:4780:11::4f', 'User Sarina Ortiz logged-in successfully'),
(198, 56, 'Login', '2023-10-06 07:50:25', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(199, 58, 'Login', '2023-10-06 07:53:40', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(200, 56, 'Login', '2023-10-06 08:00:40', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(201, 56, 'Login', '2023-10-06 08:05:13', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(202, 56, 'Login', '2023-10-06 09:27:01', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(203, 57, 'Login', '2023-10-06 09:37:17', '103.181.40.52', 'User Alen Cooper logged-in successfully'),
(204, 71, 'Login', '2023-10-06 09:48:34', '2a02:4780:11::4f', 'User Theodora Reynolds logged-in successfully'),
(205, 58, 'Login', '2023-10-06 09:52:08', '103.181.40.52', 'User John Doe logged-in successfully'),
(206, 57, 'Login', '2023-10-06 09:52:40', '103.181.40.52', 'User Alen Cooper logged-in successfully'),
(207, 58, 'Login', '2023-10-06 09:53:00', '103.181.40.52', 'User John Doe logged-in successfully'),
(208, 58, 'Login', '2023-10-06 09:59:12', '103.181.40.52', 'User John Doe logged-in successfully'),
(209, 56, 'Login', '2023-10-06 10:08:19', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(210, 56, 'Login', '2023-10-06 10:08:53', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(211, 56, 'Login', '2023-10-06 10:10:42', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(212, 59, 'Login', '2023-10-06 10:20:56', '2a02:4780:11::4f', 'User Daniel mcgril logged-in successfully'),
(213, 70, 'Login', '2023-10-06 10:30:17', '86.48.8.88', 'User Sarina Ortiz logged-in successfully'),
(214, 70, 'Login', '2023-10-06 10:31:48', '86.48.8.88', 'User Sarina Ortiz logged-in successfully'),
(215, 59, 'Login', '2023-10-06 10:32:40', '86.48.8.88', 'User Daniel mcgril logged-in successfully'),
(216, 57, 'Login', '2023-10-06 10:38:49', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(217, 58, 'Login', '2023-10-06 10:39:07', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(218, 58, 'Login', '2023-10-06 10:44:45', '103.181.40.52', 'User John Doe logged-in successfully'),
(219, 56, 'Login', '2023-10-06 10:50:38', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(220, 58, 'Login', '2023-10-06 10:51:26', '103.181.40.52', 'User John Doe logged-in successfully'),
(221, 56, 'Login', '2023-10-06 10:59:13', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(222, 56, 'Login', '2023-10-06 11:00:38', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(223, 66, 'Login', '2023-10-06 11:01:13', '2a02:4780:11::4f', 'User Brendan Rivas imporsonated by Habeeb A successfully'),
(224, 56, 'Login', '2023-10-06 11:03:02', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(225, 57, 'Login', '2023-10-06 11:18:46', '103.181.40.52', 'User Alen Cooper logged-in successfully'),
(226, 56, 'Login', '2023-10-06 11:19:08', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(227, 63, 'Login', '2023-10-06 11:20:29', '103.181.40.52', 'User Abshar Moorkath logged-in successfully'),
(228, 56, 'Login', '2023-10-06 11:21:18', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(229, 73, 'Login', '2023-10-06 11:23:20', '2a02:4780:11::4f', 'User Marcus Callum imporsonated by Habeeb A successfully'),
(230, 56, 'Login', '2023-10-06 11:24:05', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(231, 63, 'Login', '2023-10-06 11:27:17', '103.181.40.52', 'User Abshar Moorkath logged-in successfully'),
(232, 56, 'Login', '2023-10-06 11:32:57', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(233, 59, 'Login', '2023-10-06 11:49:32', '103.181.40.52', 'User Daniel mcgril logged-in successfully'),
(234, 58, 'Login', '2023-10-06 12:04:17', '103.181.40.52', 'User John Doe logged-in successfully'),
(235, 56, 'Login', '2023-10-06 12:27:55', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(236, 56, 'Login', '2023-10-06 12:34:46', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(237, 56, 'Login', '2023-10-06 12:47:38', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(238, 58, 'Login', '2023-10-06 13:13:33', '103.181.40.52', 'User John Doe logged-in successfully'),
(239, 56, 'Login', '2023-10-06 13:20:22', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(240, 56, 'Login', '2023-10-06 13:25:16', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(241, 57, 'Login', '2023-10-06 13:27:25', '103.181.40.52', 'User Alen Cooper logged-in successfully'),
(242, 58, 'Login', '2023-10-06 13:27:38', '103.181.40.52', 'User John Doe logged-in successfully'),
(243, 56, 'Login', '2023-10-06 13:37:17', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(244, 56, 'Login', '2023-10-06 13:48:06', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(245, 58, 'Login', '2023-10-06 13:57:04', '103.181.40.52', 'User John Doe logged-in successfully'),
(246, 56, 'Login', '2023-10-06 13:57:37', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(247, 56, 'Login', '2023-10-06 14:02:13', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(248, 58, 'Login', '2023-10-06 14:04:06', '103.181.40.52', 'User John Doe logged-in successfully'),
(249, 58, 'Login', '2023-10-06 14:06:38', '103.181.40.52', 'User John Doe logged-in successfully'),
(250, 58, 'Login', '2023-10-06 14:46:44', '103.181.40.52', 'User John Doe logged-in successfully'),
(251, 58, 'Login', '2023-10-06 14:46:49', '103.181.40.52', 'User John Doe logged-in successfully'),
(252, 56, 'Login', '2023-10-06 14:53:16', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(253, 59, 'Login', '2023-10-06 14:59:29', '103.181.40.52', 'User Daniel mcgril logged-in successfully'),
(254, 56, 'Login', '2023-10-06 15:10:15', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(255, 56, 'Login', '2023-10-06 15:11:43', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(256, 56, 'Login', '2023-10-06 15:29:53', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(257, 56, 'Login', '2023-10-06 16:48:44', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(258, 56, 'Login', '2023-10-06 23:02:10', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(259, 56, 'Login', '2023-10-06 23:02:11', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(260, 56, 'Login', '2023-10-06 23:59:27', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(261, 56, 'Login', '2023-10-07 00:05:56', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(262, 56, 'Login', '2023-10-07 00:20:42', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(263, 56, 'Login', '2023-10-07 05:21:59', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(264, 56, 'Login', '2023-10-07 05:25:55', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(265, 56, 'Login', '2023-10-07 05:31:51', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(266, 56, 'Login', '2023-10-07 05:34:09', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(267, 56, 'Login', '2023-10-07 05:53:35', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(268, 56, 'Login', '2023-10-07 05:54:35', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(269, 56, 'Login', '2023-10-07 08:27:19', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(270, 60, 'Logoff', '2023-10-07 09:35:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(271, 61, 'Logoff', '2023-10-07 09:36:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(272, 67, 'Logoff', '2023-10-07 09:37:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(273, 57, 'Logoff', '2023-10-07 09:38:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(274, 58, 'Logoff', '2023-10-07 09:39:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(275, 59, 'Logoff', '2023-10-07 09:40:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(276, 63, 'Logoff', '2023-10-07 09:41:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(277, 66, 'Logoff', '2023-10-07 09:42:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(278, 70, 'Logoff', '2023-10-07 09:43:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(279, 71, 'Logoff', '2023-10-07 09:43:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(280, 73, 'Logoff', '2023-10-07 09:43:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(281, 56, 'Login', '2023-10-07 09:45:46', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(282, 56, 'Logoff', '2023-10-07 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(283, 63, 'Logoff', '2023-10-07 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(284, 56, 'Login', '2023-10-07 12:33:34', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(285, 56, 'Login', '2023-10-07 14:17:35', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(286, 56, 'Logoff', '2023-10-07 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(287, 56, 'Login', '2023-10-07 23:43:46', '58.178.56.87', 'User Habeeb A logged-in successfully'),
(288, 56, 'Logoff', '2023-10-08 02:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(289, 56, 'Login', '2023-10-08 04:38:42', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(290, 59, 'Login', '2023-10-08 04:52:35', '68.178.155.83', 'User Daniel mcgril logged-in successfully'),
(291, 56, 'Login', '2023-10-08 04:56:02', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(292, 56, 'Login', '2023-10-08 05:20:30', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(293, 56, 'Login', '2023-10-08 05:21:52', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(294, 56, 'Login', '2023-10-08 05:22:17', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(295, 58, 'Login', '2023-10-08 05:22:57', '103.181.40.52', 'User John Doe logged-in successfully'),
(296, 59, 'Login', '2023-10-08 05:25:24', '103.181.40.52', 'User Daniel mcgril logged-in successfully'),
(297, 56, 'Login', '2023-10-08 05:26:35', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(298, 60, 'Logoff', '2023-10-08 06:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(299, 61, 'Logoff', '2023-10-08 06:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(300, 56, 'Login', '2023-10-08 06:05:03', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(301, 56, 'Login', '2023-10-08 06:05:22', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(302, 56, 'Login', '2023-10-08 06:18:13', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(303, 79, 'Login', '2023-10-08 06:23:02', '68.178.155.83', 'User Super Admin logged-in successfully'),
(304, 80, 'Login', '2023-10-08 06:27:37', '68.178.155.83', 'User Alana Valenzuela logged-in successfully'),
(305, 56, 'Login', '2023-10-08 06:35:22', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(306, 79, 'Login', '2023-10-08 06:36:35', '68.178.155.83', 'User Super Admin logged-in successfully'),
(307, 56, 'Login', '2023-10-08 06:41:34', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(308, 61, 'Login', '2023-10-08 06:41:50', '103.181.40.52', 'User Hannah Dooley imporsonated by Habeeb A successfully'),
(309, 59, 'Login', '2023-10-08 06:48:44', '86.48.8.125', 'User Daniel mcgril logged-in successfully'),
(310, 56, 'Login', '2023-10-08 06:48:56', '86.48.8.125', 'User Habeeb A logged-in successfully'),
(311, 81, 'Login', '2023-10-08 06:54:17', '68.178.155.83', 'User Aimee Hoffman logged-in successfully'),
(312, 83, 'Login', '2023-10-08 07:01:15', '68.178.155.83', 'User Reese Gray logged-in successfully'),
(313, 81, 'Login', '2023-10-08 07:03:13', '68.178.155.83', 'User Aimee Hoffman logged-in successfully'),
(314, 84, 'Login', '2023-10-08 07:05:52', '68.178.155.83', 'User Perry Deleon logged-in successfully'),
(315, 79, 'Login', '2023-10-08 07:08:36', '68.178.155.83', 'User Super Admin logged-in successfully'),
(316, 56, 'Login', '2023-10-08 07:21:57', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(317, 57, 'Login', '2023-10-08 07:23:49', '103.181.40.52', 'User Alen Cooper logged-in successfully'),
(318, 56, 'Login', '2023-10-08 07:32:23', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(319, 56, 'Login', '2023-10-08 07:59:11', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(320, 58, 'Logoff', '2023-10-08 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(321, 87, 'Login', '2023-10-08 08:17:43', '103.181.40.52', 'User Kyleigh Volkman logged-in successfully'),
(322, 56, 'Login', '2023-10-08 08:18:09', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(323, 58, 'Login', '2023-10-08 08:19:43', '103.181.40.52', 'User John Doe logged-in successfully'),
(324, 56, 'Login', '2023-10-08 08:27:51', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(325, 58, 'Login', '2023-10-08 08:29:08', '103.181.40.52', 'User John Doe logged-in successfully'),
(326, 63, 'Login', '2023-10-08 08:31:01', '103.181.40.52', 'User Abshar Moorkath logged-in successfully'),
(327, 59, 'Login', '2023-10-08 08:31:14', '103.181.40.52', 'User Daniel mcgril logged-in successfully'),
(328, 56, 'Login', '2023-10-08 08:33:32', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(329, 56, 'Login', '2023-10-08 08:36:38', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(330, 57, 'Login', '2023-10-08 08:37:19', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(331, 59, 'Login', '2023-10-08 08:42:44', '2a02:4780:11::4f', 'User Daniel mcgril logged-in successfully'),
(332, 56, 'Login', '2023-10-08 08:43:40', '86.48.8.127', 'User Habeeb A logged-in successfully'),
(333, 59, 'Login', '2023-10-08 08:44:34', '86.48.8.127', 'User Daniel mcgril logged-in successfully'),
(334, 80, 'Logoff', '2023-10-08 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(335, 56, 'Login', '2023-10-08 09:31:31', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(336, 56, 'Login', '2023-10-08 09:48:13', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(337, 56, 'Login', '2023-10-08 09:52:38', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(338, 79, 'Logoff', '2023-10-08 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(339, 81, 'Logoff', '2023-10-08 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(340, 83, 'Logoff', '2023-10-08 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(341, 84, 'Logoff', '2023-10-08 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(342, 58, 'Login', '2023-10-08 10:10:36', '103.181.40.52', 'User John Doe logged-in successfully'),
(343, 56, 'Login', '2023-10-08 10:13:09', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(344, 59, 'Login', '2023-10-08 10:18:41', '103.181.40.52', 'User Daniel mcgril logged-in successfully'),
(345, 56, 'Login', '2023-10-08 10:46:44', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(346, 57, 'Logoff', '2023-10-08 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(347, 63, 'Logoff', '2023-10-08 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(348, 87, 'Logoff', '2023-10-08 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(349, 56, 'Login', '2023-10-08 11:03:15', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(350, 57, 'Login', '2023-10-08 11:10:28', '103.181.40.52', 'User Alen Cooper logged-in successfully'),
(351, 58, 'Login', '2023-10-08 11:10:51', '103.181.40.52', 'User John Doe logged-in successfully'),
(352, 56, 'Login', '2023-10-08 11:12:07', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(353, 56, 'Login', '2023-10-08 11:23:16', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(354, 56, 'Login', '2023-10-08 11:23:22', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(355, 56, 'Login', '2023-10-08 12:11:57', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(356, 60, 'Login', '2023-10-08 12:13:41', '103.181.40.52', 'User Lane Kuphal imporsonated by Habeeb A successfully'),
(357, 56, 'Login', '2023-10-08 12:13:59', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(358, 63, 'Login', '2023-10-08 12:15:07', '103.181.40.52', 'User Abshar Moorkath imporsonated by Habeeb A successfully'),
(359, 56, 'Login', '2023-10-08 12:15:21', '103.181.40.52', 'User Habeeb A logged-in successfully'),
(360, 63, 'Login', '2023-10-08 12:16:26', '68.178.155.83', 'User Abshar Moorkath imporsonated by Habeeb A successfully'),
(361, 56, 'Login', '2023-10-08 12:16:37', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(362, 56, 'Login', '2023-10-08 12:23:56', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(363, 56, 'Login', '2023-10-08 12:24:31', '68.178.155.83', 'User Habeeb A logged-in successfully'),
(364, 56, 'Login', '2023-10-08 12:37:43', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(365, 59, 'Login', '2023-10-08 12:45:42', '2a02:4780:11::4f', 'User Daniel mcgril logged-in successfully'),
(366, 57, 'Login', '2023-10-08 12:46:28', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(367, 56, 'Login', '2023-10-08 12:47:47', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(368, 58, 'Logoff', '2023-10-08 14:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(369, 56, 'Logoff', '2023-10-08 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(370, 57, 'Logoff', '2023-10-08 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(371, 59, 'Logoff', '2023-10-08 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(372, 60, 'Logoff', '2023-10-08 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(373, 63, 'Logoff', '2023-10-08 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(374, 56, 'Login', '2023-10-08 22:10:59', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(375, 56, 'Login', '2023-10-08 23:38:11', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(376, 56, 'Login', '2023-10-08 23:59:12', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(377, 59, 'Login', '2023-10-09 00:28:28', '86.48.8.126', 'User Daniel mcgril logged-in successfully'),
(378, 59, 'Login', '2023-10-09 00:29:39', '86.48.8.126', 'User Daniel mcgril logged-in successfully'),
(379, 56, 'Login', '2023-10-09 00:32:36', '86.48.8.126', 'User Habeeb A logged-in successfully'),
(380, 57, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(381, 58, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(382, 60, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(383, 63, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(384, 66, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(385, 67, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(386, 70, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(387, 71, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(388, 73, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(389, 79, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(390, 80, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(391, 81, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(392, 83, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(393, 84, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(394, 87, 'Update profile', '2023-10-09 01:35:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(395, 57, 'Login', '2023-10-09 02:53:02', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(396, 56, 'Logoff', '2023-10-09 03:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(397, 59, 'Logoff', '2023-10-09 03:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(398, 58, 'Login', '2023-10-09 04:05:12', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(399, 56, 'Login', '2023-10-09 04:08:38', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(400, 57, 'Login', '2023-10-09 04:10:10', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(401, 58, 'Login', '2023-10-09 04:10:26', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(402, 56, 'Login', '2023-10-09 04:20:16', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(403, 56, 'Logoff', '2023-10-09 07:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(404, 57, 'Logoff', '2023-10-09 07:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(405, 58, 'Logoff', '2023-10-09 07:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(406, 56, 'Login', '2023-10-09 07:35:37', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(407, 56, 'Logoff', '2023-10-09 10:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(408, 56, 'Login', '2023-10-10 02:26:35', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(409, 56, 'Login', '2023-10-10 04:09:48', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(410, 89, 'Login', '2023-10-10 04:14:00', '2a02:4780:11::4f', 'User Celeste Torres logged-in successfully'),
(411, 56, 'Login', '2023-10-10 04:15:36', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(412, 90, 'Login', '2023-10-10 04:20:16', '2a02:4780:11::4f', 'User Meghan Macias logged-in successfully'),
(413, 91, 'Login', '2023-10-10 04:23:31', '2a02:4780:11::4f', 'User Colette Cameron logged-in successfully'),
(414, 56, 'Login', '2023-10-10 04:24:35', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(415, 56, 'Login', '2023-10-10 04:51:13', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(416, 92, 'Login', '2023-10-10 04:58:19', '2a02:4780:11::4f', 'User Fredericka Davis logged-in successfully'),
(417, 56, 'Login', '2023-10-10 05:03:48', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(418, 93, 'Login', '2023-10-10 05:11:03', '2a02:4780:11::4f', 'User Cameron Hinton logged-in successfully'),
(419, 94, 'Login', '2023-10-10 05:18:07', '2a02:4780:11::4f', 'User Alexis Sawyer logged-in successfully'),
(420, 56, 'Login', '2023-10-10 05:18:57', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(421, 56, 'Login', '2023-10-10 05:21:25', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(422, 94, 'Login', '2023-10-10 05:21:46', '2a02:4780:11::4f', 'User Alexis Sawyer imporsonated by Habeeb A successfully'),
(423, 56, 'Login', '2023-10-10 05:22:04', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(424, 58, 'Login', '2023-10-10 06:12:01', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(425, 56, 'Login', '2023-10-10 06:14:30', '152.58.203.115', 'User Habeeb A logged-in successfully'),
(426, 56, 'Login', '2023-10-10 06:19:59', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(427, 79, 'Login', '2023-10-10 06:20:43', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(428, 79, 'Login', '2023-10-10 06:50:58', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(429, 96, 'Login', '2023-10-10 06:59:33', '2a02:4780:11::4f', 'User Brooke Bass logged-in successfully'),
(430, 89, 'Logoff', '2023-10-10 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(431, 90, 'Logoff', '2023-10-10 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(432, 91, 'Logoff', '2023-10-10 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(433, 92, 'Logoff', '2023-10-10 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(434, 79, 'Login', '2023-10-10 07:05:15', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(435, 97, 'Login', '2023-10-10 07:11:16', '2a02:4780:11::4f', 'User Dawn Kline imporsonated by Super Admin successfully'),
(436, 79, 'Login', '2023-10-10 07:11:46', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(437, 97, 'Login', '2023-10-10 07:13:21', '2a02:4780:11::4f', 'User Dawn Kline logged-in successfully'),
(438, 79, 'Login', '2023-10-10 07:37:28', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(439, 93, 'Logoff', '2023-10-10 08:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(440, 94, 'Logoff', '2023-10-10 08:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(441, 56, 'Logoff', '2023-10-10 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(442, 58, 'Logoff', '2023-10-10 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(443, 96, 'Logoff', '2023-10-10 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(444, 79, 'Logoff', '2023-10-10 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(445, 97, 'Logoff', '2023-10-10 10:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(446, 56, 'Login', '2023-10-10 11:08:08', '103.141.55.234', 'User Habeeb A logged-in successfully'),
(447, 56, 'Login', '2023-10-10 11:10:01', '103.141.55.234', 'User Habeeb A logged-in successfully'),
(448, 57, 'Login', '2023-10-10 11:11:58', '103.141.55.234', 'User Alen Cooper logged-in successfully'),
(449, 59, 'Login', '2023-10-10 11:13:10', '103.141.55.234', 'User Daniel mcgril logged-in successfully'),
(450, 56, 'Login', '2023-10-10 11:16:22', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(451, 59, 'Login', '2023-10-10 11:20:00', '2a02:4780:11::4f', 'User Daniel mcgril imporsonated by Habeeb A successfully'),
(452, 56, 'Login', '2023-10-10 11:25:07', '2a02:4780:11::4f', 'User Habeeb A logged-in successfully'),
(453, 57, 'Login', '2023-10-10 11:40:10', '103.141.55.234', 'User Alen Cooper logged-in successfully'),
(454, 56, 'Logoff', '2023-10-10 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(455, 57, 'Logoff', '2023-10-10 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(456, 59, 'Logoff', '2023-10-10 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(457, 58, 'Login', '2023-10-11 02:44:09', '49.37.233.107', 'User John Doe logged-in successfully'),
(458, 58, 'Logoff', '2023-10-11 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(459, 56, 'Login', '2023-10-11 09:05:03', '103.181.40.56', 'User Habeeb A logged-in successfully'),
(460, 58, 'Login', '2023-10-11 09:20:40', '103.181.40.56', 'User John Doe logged-in successfully'),
(461, 56, 'Login', '2023-10-11 09:21:29', '103.181.40.56', 'User Habeeb Ra logged-in successfully'),
(462, 56, 'Login', '2023-10-11 09:25:59', '2409:40f3:1008:75e:eb77:bfea:7dd3:2fee', 'User Habeeb Ra logged-in successfully'),
(463, 56, 'Login', '2023-10-11 09:36:37', '68.178.155.83', 'User Habeeb Ra logged-in successfully'),
(464, 56, 'Login', '2023-10-11 09:36:38', '68.178.155.83', 'User Habeeb Ra logged-in successfully'),
(465, 56, 'Login', '2023-10-11 09:37:00', '68.178.155.83', 'User Habeeb Ra logged-in successfully'),
(466, 56, 'Login', '2023-10-11 09:37:01', '68.178.155.83', 'User Habeeb Ra logged-in successfully'),
(467, 59, 'Login', '2023-10-11 09:38:45', '68.178.155.83', 'User Daniel d mcgril logged-in successfully'),
(468, 56, 'Logoff', '2023-10-11 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(469, 58, 'Logoff', '2023-10-11 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(470, 59, 'Logoff', '2023-10-11 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(471, 56, 'Login', '2023-10-11 14:45:35', '103.151.189.89', 'User Habeeb Ra logged-in successfully'),
(472, 58, 'Login', '2023-10-11 14:48:07', '103.151.189.89', 'User John Doe logged-in successfully'),
(473, 56, 'Logoff', '2023-10-11 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(474, 58, 'Logoff', '2023-10-11 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(475, 56, 'Login', '2023-10-12 05:35:04', '103.141.55.234', 'User Habeeb Ra logged-in successfully'),
(476, 56, 'Login', '2023-10-12 05:36:05', '103.141.55.234', 'User Habeeb Ra logged-in successfully'),
(477, 58, 'Login', '2023-10-12 06:40:07', '103.197.115.254', 'User John Doe logged-in successfully'),
(478, 58, 'Login', '2023-10-12 07:30:27', '103.197.115.254', 'User John Doe logged-in successfully'),
(479, 56, 'Logoff', '2023-10-12 08:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry');
INSERT INTO `tbl_user_login_audit` (`userLoginAuditId`, `userProfileId`, `action`, `actionDateTime`, `deviceId`, `comments`) VALUES
(480, 57, 'Login', '2023-10-12 09:22:50', '103.141.55.234', 'User Alen Cooper logged-in successfully'),
(481, 58, 'Logoff', '2023-10-12 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(482, 56, 'Login', '2023-10-12 11:09:32', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(483, 56, 'Login', '2023-10-12 11:10:51', '68.178.155.83', 'User Habeeb Ra logged-in successfully'),
(484, 57, 'Logoff', '2023-10-12 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(485, 57, 'Login', '2023-10-12 12:11:32', '27.63.232.13', 'User Alen Cooper logged-in successfully'),
(486, 57, 'Login', '2023-10-12 12:53:18', '103.141.55.234', 'User Alen Cooper logged-in successfully'),
(487, 56, 'Logoff', '2023-10-12 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(488, 57, 'Logoff', '2023-10-12 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(489, 79, 'Update profile', '2023-10-13 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(490, 89, 'Update profile', '2023-10-13 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(491, 90, 'Update profile', '2023-10-13 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(492, 91, 'Update profile', '2023-10-13 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(493, 92, 'Update profile', '2023-10-13 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(494, 93, 'Update profile', '2023-10-13 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(495, 94, 'Update profile', '2023-10-13 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(496, 96, 'Update profile', '2023-10-13 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(497, 97, 'Update profile', '2023-10-13 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(498, 58, 'Login', '2023-10-13 02:48:04', '68.178.155.83', 'User John Doe logged-in successfully'),
(499, 59, 'Login', '2023-10-13 02:50:35', '68.178.155.83', 'User Daniel d mcgril logged-in successfully'),
(500, 58, 'Login', '2023-10-13 03:49:13', '68.178.155.83', 'User John Doe logged-in successfully'),
(501, 58, 'Login', '2023-10-13 03:53:36', '68.178.155.83', 'User John Doe logged-in successfully'),
(502, 58, 'Login', '2023-10-13 04:13:21', '68.178.155.83', 'User John Doe logged-in successfully'),
(503, 58, 'Login', '2023-10-13 04:13:22', '68.178.155.83', 'User John Doe logged-in successfully'),
(504, 59, 'Logoff', '2023-10-13 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(505, 58, 'Login', '2023-10-13 05:11:26', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(506, 56, 'Login', '2023-10-13 05:12:30', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(507, 58, 'Login', '2023-10-13 05:46:54', '49.37.235.34', 'User John Doe logged-in successfully'),
(508, 58, 'Login', '2023-10-13 05:52:00', '2405:201:f002:882f:415e:20b:446f:c677', 'User John Doe logged-in successfully'),
(509, 58, 'Login', '2023-10-13 06:52:09', '68.178.155.83', 'User John Doe logged-in successfully'),
(510, 58, 'Login', '2023-10-13 07:42:27', '49.37.235.34', 'User John Doe logged-in successfully'),
(511, 56, 'Logoff', '2023-10-13 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(512, 56, 'Login', '2023-10-13 09:58:29', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(513, 58, 'Logoff', '2023-10-13 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(514, 56, 'Login', '2023-10-13 10:11:30', '49.37.235.34', 'User Habeeb Ra logged-in successfully'),
(515, 58, 'Login', '2023-10-13 10:12:02', '49.37.235.34', 'User John Doe logged-in successfully'),
(516, 58, 'Login', '2023-10-13 11:23:44', '68.178.155.83', 'User John Doe logged-in successfully'),
(517, 56, 'Login', '2023-10-13 12:59:07', '58.178.56.87', 'User Habeeb Ra logged-in successfully'),
(518, 58, 'Logoff', '2023-10-13 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(519, 58, 'Login', '2023-10-13 14:57:10', '49.37.235.34', 'User John Doe logged-in successfully'),
(520, 56, 'Logoff', '2023-10-13 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(521, 58, 'Logoff', '2023-10-13 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(522, 56, 'Login', '2023-10-14 04:54:58', '120.18.62.165', 'User Habeeb Ra logged-in successfully'),
(523, 56, 'Login', '2023-10-14 04:56:30', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(524, 57, 'Login', '2023-10-14 04:58:18', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(525, 56, 'Login', '2023-10-14 05:01:44', '86.48.8.212', 'User Habeeb Ra logged-in successfully'),
(526, 56, 'Login', '2023-10-14 05:02:56', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(527, 57, 'Logoff', '2023-10-14 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(528, 56, 'Logoff', '2023-10-14 08:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(529, 56, 'Login', '2023-10-14 12:59:02', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(530, 58, 'Login', '2023-10-14 14:13:21', '49.37.235.34', 'User John Doe logged-in successfully'),
(531, 58, 'Login', '2023-10-14 14:22:38', '68.178.155.83', 'User John Doe logged-in successfully'),
(532, 56, 'Logoff', '2023-10-14 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(533, 58, 'Logoff', '2023-10-14 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(534, 56, 'Login', '2023-10-15 04:50:14', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(535, 56, 'Logoff', '2023-10-15 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(536, 56, 'Login', '2023-10-15 10:59:20', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(537, 56, 'Logoff', '2023-10-15 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(538, 59, 'Update profile', '2023-10-16 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(539, 58, 'Login', '2023-10-16 17:08:56', '27.63.200.25', 'User John Doe logged-in successfully'),
(540, 58, 'Logoff', '2023-10-16 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(541, 56, 'Login', '2023-10-16 22:57:55', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(542, 57, 'Update profile', '2023-10-17 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(543, 56, 'Logoff', '2023-10-17 01:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(544, 57, 'Login', '2023-10-17 02:55:33', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(545, 58, 'Login', '2023-10-17 02:56:36', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(546, 56, 'Login', '2023-10-17 02:57:25', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(547, 56, 'Login', '2023-10-17 02:59:11', '49.37.234.38', 'User Habeeb Ra logged-in successfully'),
(548, 106, 'Login', '2023-10-17 03:02:13', '2a02:4780:11::4f', 'User Derik Abraham logged-in successfully'),
(549, 58, 'Login', '2023-10-17 03:02:38', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(550, 58, 'Login', '2023-10-17 03:40:52', '68.178.155.83', 'User John Doe logged-in successfully'),
(551, 56, 'Logoff', '2023-10-17 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(552, 57, 'Logoff', '2023-10-17 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(553, 58, 'Logoff', '2023-10-17 06:00:05', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(554, 106, 'Logoff', '2023-10-17 06:00:05', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(555, 56, 'Login', '2023-10-17 10:26:26', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(556, 56, 'Logoff', '2023-10-17 13:00:05', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(557, 58, 'Login', '2023-10-17 16:44:34', '49.37.234.38', 'User John Doe logged-in successfully'),
(558, 58, 'Login', '2023-10-17 18:01:05', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(559, 58, 'Logoff', '2023-10-17 21:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(560, 56, 'Login', '2023-10-18 02:51:19', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(561, 56, 'Logoff', '2023-10-18 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(562, 56, 'Login', '2023-10-18 10:07:34', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(563, 56, 'Logoff', '2023-10-18 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(564, 58, 'Login', '2023-10-18 16:17:18', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(565, 58, 'Login', '2023-10-18 16:17:53', '49.37.234.38', 'User John Doe logged-in successfully'),
(566, 56, 'Login', '2023-10-18 16:18:33', '2405:201:f002:882f:49d4:4c28:5a47:a112', 'User Habeeb Ra logged-in successfully'),
(567, 58, 'Login', '2023-10-18 16:23:35', '49.37.234.38', 'User John Doe logged-in successfully'),
(568, 56, 'Logoff', '2023-10-18 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(569, 58, 'Logoff', '2023-10-18 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(570, 58, 'Login', '2023-10-19 02:42:47', '2405:201:f002:882f:49d4:4c28:5a47:a112', 'User John Doe logged-in successfully'),
(571, 58, 'Logoff', '2023-10-19 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(572, 57, 'Update profile', '2023-10-20 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(573, 106, 'Update profile', '2023-10-20 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(574, 56, 'Login', '2023-10-20 10:06:17', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(575, 56, 'Login', '2023-10-20 10:08:02', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(576, 56, 'Login', '2023-10-20 10:09:24', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(577, 57, 'Login', '2023-10-20 10:12:03', '2a02:4780:11::4f', 'User Alen Cooper imporsonated by Habeeb Ra successfully'),
(578, 56, 'Login', '2023-10-20 10:12:48', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(579, 63, 'Login', '2023-10-20 10:13:36', '2a02:4780:11::4f', 'User Abshar Moorkath imporsonated by Habeeb Ra successfully'),
(580, 56, 'Login', '2023-10-20 10:13:58', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(581, 86, 'Login', '2023-10-20 10:14:41', '2a02:4780:11::4f', 'User Susana c Dickinson imporsonated by Habeeb Ra successfully'),
(582, 56, 'Logoff', '2023-10-20 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(583, 57, 'Logoff', '2023-10-20 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(584, 63, 'Logoff', '2023-10-20 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(585, 86, 'Logoff', '2023-10-20 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(586, 58, 'Update profile', '2023-10-22 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(587, 56, 'Update profile', '2023-10-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(588, 57, 'Update profile', '2023-10-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(589, 63, 'Update profile', '2023-10-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(590, 86, 'Update profile', '2023-10-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(591, 56, 'Login', '2023-10-23 00:12:18', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(592, 56, 'Login', '2023-10-23 00:13:27', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(593, 56, 'Logoff', '2023-10-23 03:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(594, 58, 'Login', '2023-10-23 11:51:35', '103.140.16.103', 'User John Doe logged-in successfully'),
(595, 58, 'Login', '2023-10-23 11:54:21', '103.140.16.103', 'User John Doe logged-in successfully'),
(596, 58, 'Logoff', '2023-10-23 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(597, 58, 'Login', '2023-10-24 03:59:21', '103.140.16.103', 'User John Doe logged-in successfully'),
(598, 58, 'Logoff', '2023-10-24 06:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(599, 58, 'Login', '2023-10-25 17:02:54', '2405:201:f002:882f:9485:ee15:30db:9db0', 'User John Doe logged-in successfully'),
(600, 58, 'Login', '2023-10-25 18:31:55', '49.37.234.38', 'User John Doe logged-in successfully'),
(601, 58, 'Login', '2023-10-25 19:00:15', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(602, 58, 'Logoff', '2023-10-25 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(603, 56, 'Update profile', '2023-10-26 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(604, 58, 'Login', '2023-10-26 10:21:26', '103.141.55.234', 'User John Doe logged-in successfully'),
(605, 56, 'Login', '2023-10-26 11:22:17', '103.141.55.234', 'User Habeeb Ra logged-in successfully'),
(606, 58, 'Login', '2023-10-26 11:23:05', '103.141.55.234', 'User John Doe logged-in successfully'),
(607, 58, 'Login', '2023-10-26 13:02:15', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(608, 58, 'Login', '2023-10-26 13:02:25', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(609, 58, 'Login', '2023-10-26 13:02:26', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(610, 58, 'Login', '2023-10-26 13:02:50', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(611, 58, 'Login', '2023-10-26 13:02:50', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(612, 106, 'Login', '2023-10-26 13:03:08', '2a02:4780:11::4f', 'User Derik Abraham logged-in successfully'),
(613, 56, 'Logoff', '2023-10-26 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(614, 58, 'Logoff', '2023-10-26 16:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(615, 106, 'Logoff', '2023-10-26 16:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(616, 58, 'Login', '2023-10-26 16:04:38', '49.37.234.38', 'User John Doe logged-in successfully'),
(617, 58, 'Login', '2023-10-26 16:14:13', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(618, 58, 'Logoff', '2023-10-26 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(619, 58, 'Login', '2023-10-27 04:59:46', '103.141.55.234', 'User John Doe logged-in successfully'),
(620, 106, 'Login', '2023-10-27 05:19:45', '2a02:4780:11::4f', 'User Derik Abraham logged-in successfully'),
(621, 58, 'Login', '2023-10-27 05:20:03', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(622, 58, 'Login', '2023-10-27 06:34:24', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(623, 58, 'Login', '2023-10-27 06:34:25', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(624, 106, 'Logoff', '2023-10-27 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(625, 58, 'Logoff', '2023-10-27 09:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(626, 56, 'Login', '2023-10-27 10:07:06', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(627, 58, 'Login', '2023-10-27 11:11:05', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(628, 58, 'Login', '2023-10-27 11:11:06', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(629, 56, 'Login', '2023-10-27 11:16:03', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(630, 56, 'Logoff', '2023-10-27 14:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(631, 58, 'Logoff', '2023-10-27 14:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(632, 58, 'Login', '2023-10-27 16:01:33', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(633, 58, 'Login', '2023-10-27 16:20:16', '49.37.234.38', 'User John Doe logged-in successfully'),
(634, 56, 'Login', '2023-10-27 16:42:29', '49.37.234.38', 'User Habeeb Ra logged-in successfully'),
(635, 58, 'Login', '2023-10-27 16:44:16', '49.37.234.38', 'User John Doe logged-in successfully'),
(636, 58, 'Login', '2023-10-27 17:39:23', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(637, 56, 'Logoff', '2023-10-27 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(638, 58, 'Login', '2023-10-27 19:49:10', '49.37.234.38', 'User John Doe logged-in successfully'),
(639, 58, 'Logoff', '2023-10-27 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(640, 56, 'Login', '2023-10-28 00:06:00', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(641, 56, 'Logoff', '2023-10-28 03:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(642, 58, 'Login', '2023-10-28 03:14:13', '49.37.234.38', 'User John Doe logged-in successfully'),
(643, 56, 'Login', '2023-10-28 04:15:28', '120.18.108.20', 'User Habeeb Ra logged-in successfully'),
(644, 58, 'Logoff', '2023-10-28 06:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(645, 56, 'Logoff', '2023-10-28 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(646, 56, 'Login', '2023-10-28 10:49:12', '120.18.148.193', 'User Habeeb Ra logged-in successfully'),
(647, 56, 'Login', '2023-10-28 10:50:33', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(648, 56, 'Logoff', '2023-10-28 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(649, 58, 'Login', '2023-10-28 14:57:18', '2405:201:f002:882f:b8b0:692d:6c75:e2ad', 'User John Doe logged-in successfully'),
(650, 56, 'Login', '2023-10-28 15:02:55', '49.37.234.38', 'User Habeeb Ra logged-in successfully'),
(651, 58, 'Logoff', '2023-10-28 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(652, 56, 'Logoff', '2023-10-28 18:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(653, 56, 'Login', '2023-10-29 01:35:14', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(654, 56, 'Logoff', '2023-10-29 04:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(655, 58, 'Login', '2023-10-29 07:30:13', '49.37.234.38', 'User John Doe logged-in successfully'),
(656, 58, 'Login', '2023-10-29 08:10:18', '49.37.234.38', 'User John Doe logged-in successfully'),
(657, 58, 'Logoff', '2023-10-29 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(658, 58, 'Login', '2023-10-29 13:02:55', '49.37.233.79', 'User John Doe logged-in successfully'),
(659, 58, 'Logoff', '2023-10-29 16:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(660, 56, 'Login', '2023-10-29 22:49:52', '58.178.56.87', 'User Habeeb Ra logged-in successfully'),
(661, 106, 'Update profile', '2023-10-30 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(662, 56, 'Logoff', '2023-10-30 01:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(663, 58, 'Login', '2023-10-30 06:30:17', '103.141.55.234', 'User John Doe logged-in successfully'),
(664, 58, 'Login', '2023-10-30 06:51:10', '103.141.55.234', 'User John Doe logged-in successfully'),
(665, 56, 'Login', '2023-10-30 07:02:26', '103.141.55.234', 'User Habeeb Ra logged-in successfully'),
(666, 56, 'Login', '2023-10-30 07:27:56', '103.141.55.234', 'User Habeeb Ra logged-in successfully'),
(667, 58, 'Login', '2023-10-30 08:00:28', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(668, 58, 'Login', '2023-10-30 08:00:29', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(669, 58, 'Login', '2023-10-30 08:49:28', '103.141.55.234', 'User John Doe logged-in successfully'),
(670, 57, 'Login', '2023-10-30 08:52:21', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(671, 56, 'Login', '2023-10-30 08:52:48', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(672, 56, 'Logoff', '2023-10-30 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(673, 57, 'Logoff', '2023-10-30 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(674, 58, 'Logoff', '2023-10-30 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(675, 56, 'Login', '2023-10-30 12:18:17', '103.141.55.234', 'User Habeeb Ra logged-in successfully'),
(676, 56, 'Login', '2023-10-30 12:19:20', '103.141.55.234', 'User Habeeb Ra logged-in successfully'),
(677, 56, 'Login', '2023-10-30 12:51:37', '103.141.55.234', 'User Habeeb Ra logged-in successfully'),
(678, 58, 'Login', '2023-10-30 13:27:45', '103.141.55.234', 'User John Doe logged-in successfully'),
(679, 56, 'Logoff', '2023-10-30 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(680, 58, 'Logoff', '2023-10-30 16:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(681, 56, 'Login', '2023-10-31 04:27:09', '103.141.55.234', 'User Habeeb Ra logged-in successfully'),
(682, 58, 'Login', '2023-10-31 05:14:05', '103.141.55.234', 'User John Doe logged-in successfully'),
(683, 56, 'Logoff', '2023-10-31 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(684, 58, 'Logoff', '2023-10-31 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(685, 56, 'Login', '2023-10-31 12:08:52', '202.88.246.56', 'User Habeeb Ra logged-in successfully'),
(686, 56, 'Login', '2023-10-31 12:45:19', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(687, 56, 'Logoff', '2023-10-31 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(688, 56, 'Login', '2023-10-31 15:23:23', '49.37.233.79', 'User Habeeb Ra logged-in successfully'),
(689, 56, 'Login', '2023-10-31 17:04:26', '49.37.233.79', 'User Habeeb Ra logged-in successfully'),
(690, 58, 'Login', '2023-10-31 17:38:03', '49.37.233.79', 'User John Doe logged-in successfully'),
(691, 56, 'Login', '2023-10-31 17:59:17', '49.37.233.79', 'User Habeeb Ra logged-in successfully'),
(692, 56, 'Logoff', '2023-10-31 20:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(693, 58, 'Logoff', '2023-10-31 20:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(694, 57, 'Update profile', '2023-11-02 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(695, 56, 'Update profile', '2023-11-03 00:00:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(696, 58, 'Update profile', '2023-11-03 00:00:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(697, 56, 'Login', '2023-11-04 05:47:27', '2405:201:f002:882f:d003:a203:3bee:7f83', 'User Habeeb Ra logged-in successfully'),
(698, 56, 'Login', '2023-11-04 06:19:49', '61.3.211.130', 'User Habeeb Ra logged-in successfully'),
(699, 56, 'Login', '2023-11-04 06:23:26', '49.37.235.57', 'User Habeeb Ra logged-in successfully'),
(700, 56, 'Login', '2023-11-04 06:24:10', '49.37.235.57', 'User Habeeb Ra logged-in successfully'),
(701, 56, 'Login', '2023-11-04 06:28:09', '2a02:4780:11::4f', 'User Habeeb Ra logged-in successfully'),
(702, 56, 'Login', '2023-11-04 07:51:00', '49.37.235.57', 'User Habeeb Rahman logged-in successfully'),
(703, 56, 'Logoff', '2023-11-04 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(704, 56, 'Login', '2023-11-04 11:08:58', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(705, 60, 'Logoff', '2023-11-04 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(706, 56, 'Login', '2023-11-04 13:54:47', '49.37.235.57', 'User Habeeb Rahman logged-in successfully'),
(707, 57, 'Logoff', '2023-11-04 15:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(708, 58, 'Login', '2023-11-04 15:18:57', '49.37.235.57', 'User John Doe logged-in successfully'),
(709, 56, 'Login', '2023-11-04 15:20:15', '49.37.235.57', 'User Habeeb Rahman logged-in successfully'),
(710, 57, 'Logoff', '2023-11-04 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(711, 56, 'Logoff', '2023-11-04 18:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(712, 58, 'Logoff', '2023-11-04 18:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(713, 56, 'Login', '2023-11-05 09:30:54', '49.37.233.121', 'User Habeeb Rahman logged-in successfully'),
(714, 56, 'Login', '2023-11-05 09:37:00', '49.37.233.121', 'User Habeeb Rahman logged-in successfully'),
(715, 56, 'Login', '2023-11-05 09:55:23', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(716, 58, 'Login', '2023-11-05 10:20:53', '49.37.233.121', 'User John Doe logged-in successfully'),
(717, 56, 'Login', '2023-11-05 10:22:57', '49.37.233.121', 'User Habeeb Rahman logged-in successfully'),
(718, 56, 'Login', '2023-11-05 10:37:52', '49.37.233.121', 'User Habeeb Rahman logged-in successfully'),
(719, 56, 'Logoff', '2023-11-05 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(720, 58, 'Logoff', '2023-11-05 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(721, 56, 'Login', '2023-11-05 17:13:41', '49.37.233.121', 'User Habeeb Rahman logged-in successfully'),
(722, 56, 'Login', '2023-11-05 17:14:11', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(723, 56, 'Login', '2023-11-05 17:41:30', '49.37.233.121', 'User Habeeb Rahman logged-in successfully'),
(724, 56, 'Login', '2023-11-05 18:46:33', '49.37.233.121', 'User Habeeb Rahman logged-in successfully'),
(725, 56, 'Logoff', '2023-11-05 21:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(726, 56, 'Login', '2023-11-06 02:18:36', '49.37.233.121', 'User Habeeb Rahman logged-in successfully'),
(727, 56, 'Logoff', '2023-11-06 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(728, 56, 'Login', '2023-11-06 10:13:14', '106.194.40.6', 'User Habeeb Rahman logged-in successfully'),
(729, 108, 'Login', '2023-11-06 10:15:43', '202.88.246.56', 'User Teacher Test logged-in successfully'),
(730, 56, 'Login', '2023-11-06 10:16:08', '202.88.246.56', 'User Habeeb Rahman logged-in successfully'),
(731, 108, 'Login', '2023-11-06 10:16:58', '202.88.246.56', 'User Teacher Test logged-in successfully'),
(732, 57, 'Login', '2023-11-06 10:25:11', '103.141.55.234', 'User Alen Cooper2 logged-in successfully'),
(733, 56, 'Login', '2023-11-06 10:25:46', '103.141.55.234', 'User Habeeb Rahman logged-in successfully'),
(734, 66, 'Login', '2023-11-06 10:27:06', '103.141.55.234', 'User Brendan e Rivas logged-in successfully'),
(735, 108, 'Login', '2023-11-06 11:32:39', '103.141.55.234', 'User Teacher Test logged-in successfully'),
(736, 56, 'Logoff', '2023-11-06 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(737, 57, 'Logoff', '2023-11-06 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(738, 66, 'Logoff', '2023-11-06 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(739, 108, 'Logoff', '2023-11-06 14:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(740, 58, 'Login', '2023-11-06 15:27:36', '49.37.234.204', 'User John Doe logged-in successfully'),
(741, 56, 'Login', '2023-11-06 15:32:40', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(742, 56, 'Login', '2023-11-06 15:39:38', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(743, 58, 'Login', '2023-11-06 15:40:35', '49.37.234.204', 'User John Doe logged-in successfully'),
(744, 57, 'Login', '2023-11-06 15:48:14', '49.37.234.204', 'User Alen Cooper2 logged-in successfully'),
(745, 56, 'Login', '2023-11-06 15:48:39', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(746, 57, 'Login', '2023-11-06 15:51:14', '49.37.234.204', 'User Alen Cooper logged-in successfully'),
(747, 57, 'Login', '2023-11-06 15:51:46', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(748, 56, 'Login', '2023-11-06 15:57:18', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(749, 56, 'Login', '2023-11-06 16:26:35', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(750, 108, 'Login', '2023-11-06 16:33:45', '2a02:4780:11::4f', 'User Teacher Test logged-in successfully'),
(751, 57, 'Login', '2023-11-06 17:15:54', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(752, 56, 'Login', '2023-11-06 17:16:16', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(753, 108, 'Login', '2023-11-06 17:28:01', '49.37.234.204', 'User Teacher Test logged-in successfully'),
(754, 56, 'Login', '2023-11-06 17:35:53', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(755, 108, 'Login', '2023-11-06 17:48:29', '49.37.234.204', 'User Teacher Test logged-in successfully'),
(756, 56, 'Login', '2023-11-06 17:50:35', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(757, 108, 'Login', '2023-11-06 17:56:06', '49.37.234.204', 'User Teacher Test logged-in successfully'),
(758, 56, 'Login', '2023-11-06 17:59:56', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(759, 58, 'Logoff', '2023-11-06 18:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(760, 108, 'Login', '2023-11-06 18:03:45', '49.37.234.204', 'User Teacher Test logged-in successfully'),
(761, 57, 'Login', '2023-11-06 18:04:08', '49.37.234.204', 'User Alen Cooper logged-in successfully'),
(762, 56, 'Login', '2023-11-06 18:04:23', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(763, 108, 'Login', '2023-11-06 18:12:42', '2405:201:f002:882f:b8f1:e123:c6a2:93bd', 'User Teacher Test logged-in successfully'),
(764, 56, 'Login', '2023-11-06 18:13:48', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(765, 108, 'Login', '2023-11-06 18:14:58', '49.37.234.204', 'User Teacher Test logged-in successfully'),
(766, 56, 'Login', '2023-11-06 18:15:47', '49.37.234.204', 'User Habeeb Rahman logged-in successfully'),
(767, 56, 'Logoff', '2023-11-06 21:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(768, 57, 'Logoff', '2023-11-06 21:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(769, 108, 'Logoff', '2023-11-06 21:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(770, 60, 'Update profile', '2023-11-07 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(771, 56, 'Login', '2023-11-07 15:44:21', '49.37.235.37', 'User Habeeb Rahman logged-in successfully'),
(772, 108, 'Login', '2023-11-07 15:44:39', '2405:201:f002:882f:c4b8:bde8:2002:f7b3', 'User Teacher Test logged-in successfully'),
(773, 56, 'Login', '2023-11-07 15:47:11', '49.37.235.37', 'User Habeeb Rahman logged-in successfully'),
(774, 108, 'Login', '2023-11-07 15:49:28', '49.37.235.37', 'User Teacher Test logged-in successfully'),
(775, 56, 'Login', '2023-11-07 15:53:53', '49.37.235.37', 'User Habeeb Rahman logged-in successfully'),
(776, 108, 'Login', '2023-11-07 15:57:39', '49.37.235.37', 'User Teacher Test logged-in successfully'),
(777, 56, 'Login', '2023-11-07 15:58:49', '49.37.235.37', 'User Habeeb Rahman logged-in successfully'),
(778, 108, 'Login', '2023-11-07 16:03:44', '49.37.235.37', 'User Teacher Test logged-in successfully'),
(779, 56, 'Login', '2023-11-07 16:04:16', '49.37.235.37', 'User Habeeb Rahman logged-in successfully'),
(780, 58, 'Login', '2023-11-07 16:05:00', '49.37.235.37', 'User John Doe logged-in successfully'),
(781, 108, 'Login', '2023-11-07 16:06:02', '49.37.235.37', 'User Teacher Test logged-in successfully'),
(782, 56, 'Login', '2023-11-07 16:06:24', '2405:201:f002:882f:c4b8:bde8:2002:f7b3', 'User Habeeb Rahman logged-in successfully'),
(783, 58, 'Login', '2023-11-07 16:06:49', '49.37.235.37', 'User John Doe logged-in successfully'),
(784, 71, 'Login', '2023-11-07 16:07:31', '49.37.235.37', 'User Theodora Reynolds logged-in successfully'),
(785, 56, 'Logoff', '2023-11-07 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(786, 58, 'Logoff', '2023-11-07 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(787, 71, 'Logoff', '2023-11-07 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(788, 108, 'Logoff', '2023-11-07 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(789, 56, 'Login', '2023-11-07 21:11:50', '49.37.235.37', 'User Habeeb Rahman logged-in successfully'),
(790, 71, 'Login', '2023-11-07 21:12:14', '2405:201:f002:882f:95c7:7a31:d17:d272', 'User Theodora Reynolds logged-in successfully'),
(791, 58, 'Login', '2023-11-07 21:14:28', '2405:201:f002:882f:95c7:7a31:d17:d272', 'User John Doe logged-in successfully'),
(792, 56, 'Logoff', '2023-11-08 00:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(793, 58, 'Logoff', '2023-11-08 00:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(794, 71, 'Logoff', '2023-11-08 00:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(795, 56, 'Login', '2023-11-08 04:49:36', '103.141.55.234', 'User Habeeb Rahman logged-in successfully'),
(796, 108, 'Login', '2023-11-08 04:50:14', '202.88.246.56', 'User Teacher Test logged-in successfully'),
(797, 56, 'Login', '2023-11-08 04:53:28', '202.88.246.56', 'User Habeeb Rahman logged-in successfully'),
(798, 108, 'Login', '2023-11-08 04:53:49', '202.88.246.56', 'User Teacher Test logged-in successfully'),
(799, 56, 'Login', '2023-11-08 04:59:20', '202.88.246.56', 'User Habeeb Rahman logged-in successfully'),
(800, 108, 'Login', '2023-11-08 04:59:43', '202.88.246.56', 'User Teacher Test logged-in successfully'),
(801, 57, 'Login', '2023-11-08 05:09:30', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(802, 56, 'Logoff', '2023-11-08 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(803, 108, 'Logoff', '2023-11-08 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(804, 57, 'Logoff', '2023-11-08 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(805, 56, 'Login', '2023-11-08 08:17:49', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(806, 56, 'Logoff', '2023-11-08 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(807, 58, 'Login', '2023-11-08 16:26:39', '2405:201:f002:882f:c5da:defc:edd2:39f6', 'User John Doe logged-in successfully'),
(808, 58, 'Login', '2023-11-08 16:39:45', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(809, 58, 'Login', '2023-11-08 16:51:00', '49.37.232.122', 'User John Doe logged-in successfully'),
(810, 108, 'Login', '2023-11-08 16:58:24', '49.37.232.122', 'User Teacher Test logged-in successfully'),
(811, 56, 'Login', '2023-11-08 17:04:12', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(812, 108, 'Login', '2023-11-08 17:05:12', '49.37.232.122', 'User Teacher Test logged-in successfully'),
(813, 56, 'Login', '2023-11-08 17:05:30', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(814, 108, 'Login', '2023-11-08 17:06:55', '49.37.232.122', 'User Teacher Test logged-in successfully'),
(815, 56, 'Login', '2023-11-08 17:13:23', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(816, 56, 'Login', '2023-11-08 17:35:46', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(817, 57, 'Login', '2023-11-08 17:36:37', '49.37.232.122', 'User Alen Cooper logged-in successfully'),
(818, 56, 'Login', '2023-11-08 17:37:10', '2405:201:f002:882f:c5da:defc:edd2:39f6', 'User Habeeb Rahman logged-in successfully'),
(819, 56, 'Login', '2023-11-08 18:10:34', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(820, 56, 'Login', '2023-11-08 18:34:33', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(821, 57, 'Login', '2023-11-08 18:35:32', '49.37.232.122', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(822, 57, 'Login', '2023-11-08 18:53:44', '49.37.232.122', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(823, 57, 'Login', '2023-11-08 18:55:14', '49.37.232.122', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(824, 58, 'Logoff', '2023-11-08 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(825, 56, 'Login', '2023-11-08 19:22:47', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(826, 108, 'Logoff', '2023-11-08 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(827, 57, 'Login', '2023-11-08 20:39:03', '49.37.232.122', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(828, 56, 'Login', '2023-11-08 20:41:24', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(829, 57, 'Login', '2023-11-08 20:41:46', '2405:201:f002:882f:c5da:defc:edd2:39f6', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(830, 56, 'Login', '2023-11-08 20:43:10', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(831, 57, 'Login', '2023-11-08 20:43:22', '49.37.232.122', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(832, 56, 'Login', '2023-11-08 20:45:47', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(833, 73, 'Login', '2023-11-08 20:47:27', '49.37.232.122', 'User Marcus Callum imporsonated by Habeeb Rahman successfully'),
(834, 56, 'Login', '2023-11-08 20:50:51', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(835, 58, 'Login', '2023-11-08 20:51:15', '49.37.232.122', 'User John Doe imporsonated by Habeeb Rahman successfully'),
(836, 56, 'Login', '2023-11-08 20:51:32', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(837, 57, 'Login', '2023-11-08 20:51:45', '49.37.232.122', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(838, 56, 'Login', '2023-11-08 20:52:13', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(839, 63, 'Login', '2023-11-08 20:52:44', '49.37.232.122', 'User Abshar Moorkath imporsonated by Habeeb Rahman successfully'),
(840, 56, 'Logoff', '2023-11-08 23:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(841, 57, 'Logoff', '2023-11-08 23:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(842, 58, 'Logoff', '2023-11-08 23:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(843, 63, 'Logoff', '2023-11-08 23:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(844, 73, 'Logoff', '2023-11-08 23:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(845, 66, 'Update profile', '2023-11-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(846, 56, 'Login', '2023-11-09 02:54:03', '49.37.232.122', 'User Habeeb Rahman logged-in successfully'),
(847, 57, 'Login', '2023-11-09 02:54:21', '49.37.232.122', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(848, 58, 'Login', '2023-11-09 02:58:48', '49.37.232.122', 'User John Doe logged-in successfully'),
(849, 56, 'Logoff', '2023-11-09 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(850, 57, 'Logoff', '2023-11-09 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(851, 58, 'Logoff', '2023-11-09 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(852, 56, 'Login', '2023-11-09 15:45:08', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(853, 56, 'Login', '2023-11-09 16:05:31', '2405:201:f002:882f:95c7:7a31:d17:d272', 'User Habeeb Rahman logged-in successfully'),
(854, 56, 'Login', '2023-11-09 16:10:38', '2405:201:f002:882f:95c7:7a31:d17:d272', 'User Habeeb Rahman logged-in successfully'),
(855, 58, 'Login', '2023-11-09 17:46:50', '49.37.234.58', 'User John Doe logged-in successfully'),
(856, 56, 'Login', '2023-11-09 17:47:22', '49.37.234.58', 'User Habeeb Rahman logged-in successfully'),
(857, 58, 'Login', '2023-11-09 17:54:58', '49.37.234.58', 'User John Doe logged-in successfully'),
(858, 56, 'Login', '2023-11-09 17:55:23', '49.37.234.58', 'User Habeeb Rahman logged-in successfully'),
(859, 58, 'Login', '2023-11-09 17:55:58', '49.37.234.58', 'User John Doe logged-in successfully'),
(860, 56, 'Login', '2023-11-09 17:57:02', '49.37.234.58', 'User Habeeb Rahman logged-in successfully'),
(861, 57, 'Logoff', '2023-11-09 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(862, 56, 'Logoff', '2023-11-09 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(863, 58, 'Logoff', '2023-11-09 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(864, 57, 'Logoff', '2023-11-09 21:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(865, 56, 'Login', '2023-11-10 01:49:56', '27.63.200.7', 'User Habeeb Rahman logged-in successfully'),
(866, 56, 'Logoff', '2023-11-10 04:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(867, 56, 'Login', '2023-11-10 18:51:30', '2405:201:f002:882f:95c7:7a31:d17:d272', 'User Habeeb Rahman logged-in successfully'),
(868, 56, 'Logoff', '2023-11-10 21:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(869, 71, 'Update profile', '2023-11-11 00:00:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(870, 108, 'Update profile', '2023-11-11 00:00:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(871, 57, 'Update profile', '2023-11-12 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(872, 58, 'Update profile', '2023-11-12 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(873, 63, 'Update profile', '2023-11-12 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(874, 73, 'Update profile', '2023-11-12 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(875, 56, 'Login', '2023-11-12 05:13:58', '49.37.233.70', 'User Habeeb Rahman logged-in successfully'),
(876, 56, 'Login', '2023-11-12 05:22:15', '49.37.233.70', 'User Habeeb Rahman logged-in successfully'),
(877, 56, 'Logoff', '2023-11-12 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(878, 56, 'Update profile', '2023-11-15 00:00:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(879, 56, 'Login', '2023-11-15 06:34:36', '157.44.191.195', 'User Habeeb Rahman logged-in successfully'),
(880, 56, 'Login', '2023-11-15 06:53:29', '157.44.191.195', 'User Habeeb Rahman logged-in successfully'),
(881, 56, 'Login', '2023-11-15 07:08:30', '202.88.246.56', 'User Habeeb Rahman logged-in successfully'),
(882, 109, 'Login', '2023-11-15 07:33:39', '157.44.191.195', 'User Dominic jhon logged-in successfully'),
(883, 56, 'Login', '2023-11-15 07:45:09', '157.44.191.195', 'User Habeeb Rahman logged-in successfully'),
(884, 56, 'Login', '2023-11-15 07:55:17', '157.44.191.195', 'User Habeeb Rahman logged-in successfully'),
(885, 112, 'Login', '2023-11-15 07:58:40', '157.44.191.195', 'User elisa sam logged-in successfully'),
(886, 110, 'Login', '2023-11-15 07:58:53', '2409:4073:206:83e5::250c:50a4', 'User brian sam logged-in successfully'),
(887, 111, 'Login', '2023-11-15 07:59:40', '157.44.191.195', 'User tejj haward logged-in successfully'),
(888, 56, 'Login', '2023-11-15 07:59:51', '2409:4073:206:83e5::250c:50a4', 'User Habeeb Rahman logged-in successfully'),
(889, 63, 'Logoff', '2023-11-15 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(890, 109, 'Login', '2023-11-15 08:02:46', '157.44.191.195', 'User Dominic jhon logged-in successfully'),
(891, 56, 'Logoff', '2023-11-15 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(892, 110, 'Logoff', '2023-11-15 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(893, 111, 'Logoff', '2023-11-15 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(894, 112, 'Logoff', '2023-11-15 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(895, 109, 'Logoff', '2023-11-15 11:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(896, 56, 'Login', '2023-11-15 14:22:37', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(897, 58, 'Login', '2023-11-15 14:24:04', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(898, 79, 'Login', '2023-11-15 14:24:09', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(899, 79, 'Login', '2023-11-15 14:26:15', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(900, 56, 'Login', '2023-11-15 15:18:35', '2409:4073:206:83e5::250c:50a4', 'User Habeeb Rahman logged-in successfully'),
(901, 56, 'Login', '2023-11-15 15:20:56', '157.44.165.132', 'User Habeeb Rahman logged-in successfully'),
(902, 56, 'Login', '2023-11-15 15:53:53', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(903, 56, 'Login', '2023-11-15 15:54:39', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(904, 58, 'Logoff', '2023-11-15 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(905, 79, 'Logoff', '2023-11-15 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(906, 56, 'Login', '2023-11-15 17:26:22', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(907, 56, 'Login', '2023-11-15 17:28:27', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(908, 56, 'Login', '2023-11-15 17:29:21', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(909, 56, 'Login', '2023-11-15 17:33:50', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(910, 56, 'Logoff', '2023-11-15 20:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(911, 79, 'Login', '2023-11-16 03:12:46', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(912, 79, 'Logoff', '2023-11-16 06:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(913, 79, 'Login', '2023-11-16 07:08:28', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(914, 79, 'Login', '2023-11-16 08:52:56', '106.200.23.77', 'User Super Admin logged-in successfully'),
(915, 79, 'Logoff', '2023-11-16 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(916, 56, 'Login', '2023-11-16 12:12:32', '202.88.246.56', 'User Habeeb Rahman logged-in successfully'),
(917, 56, 'Logoff', '2023-11-16 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(918, 58, 'Update profile', '2023-11-18 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(919, 63, 'Update profile', '2023-11-18 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(920, 109, 'Update profile', '2023-11-18 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(921, 110, 'Update profile', '2023-11-18 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(922, 111, 'Update profile', '2023-11-18 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(923, 112, 'Update profile', '2023-11-18 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(924, 56, 'Login', '2023-11-18 09:21:59', '103.151.188.191', 'User Habeeb Rahman logged-in successfully'),
(925, 56, 'Logoff', '2023-11-18 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(926, 79, 'Update profile', '2023-11-19 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity');
INSERT INTO `tbl_user_login_audit` (`userLoginAuditId`, `userProfileId`, `action`, `actionDateTime`, `deviceId`, `comments`) VALUES
(927, 56, 'Update profile', '2023-11-21 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(928, 79, 'Login', '2023-11-24 14:05:49', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(929, 79, 'Logoff', '2023-11-24 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(930, 56, 'Login', '2023-11-25 07:02:14', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(931, 56, 'Login', '2023-11-25 07:02:33', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(932, 56, 'Logoff', '2023-11-25 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(933, 79, 'Update profile', '2023-11-27 00:00:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(934, 79, 'Login', '2023-11-27 06:33:08', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(935, 79, 'Logoff', '2023-11-27 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(936, 79, 'Login', '2023-11-27 10:17:07', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(937, 79, 'Logoff', '2023-11-27 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(938, 56, 'Update profile', '2023-11-28 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(939, 79, 'Login', '2023-11-28 12:30:02', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(940, 79, 'Logoff', '2023-11-28 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(941, 79, 'Login', '2023-11-28 16:33:31', '27.57.56.160', 'User Super Admin logged-in successfully'),
(942, 56, 'Login', '2023-11-28 17:58:01', '49.37.226.196', 'User Habeeb Rahman logged-in successfully'),
(943, 79, 'Logoff', '2023-11-28 19:00:05', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(944, 56, 'Logoff', '2023-11-28 20:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(945, 79, 'Login', '2023-11-29 06:52:27', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(946, 93, 'Login', '2023-11-29 07:22:48', '2a02:4780:11::4f', 'User Cameron Hinton logged-in successfully'),
(947, 79, 'Logoff', '2023-11-29 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(948, 93, 'Logoff', '2023-11-29 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(949, 79, 'Login', '2023-11-29 10:06:31', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(950, 93, 'Login', '2023-11-29 10:07:00', '2a02:4780:11::4f', 'User Cameron Hinton logged-in successfully'),
(951, 115, 'Login', '2023-11-29 12:35:31', '2a02:4780:11::4f', 'User Genevieve Lambert logged-in successfully'),
(952, 79, 'Logoff', '2023-11-29 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(953, 93, 'Logoff', '2023-11-29 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(954, 58, 'Login', '2023-11-29 13:08:18', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(955, 58, 'Login', '2023-11-29 13:18:16', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(956, 58, 'Login', '2023-11-29 13:43:30', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(957, 58, 'Login', '2023-11-29 13:54:36', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(958, 58, 'Login', '2023-11-29 13:55:34', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(959, 58, 'Login', '2023-11-29 13:56:09', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(960, 56, 'Login', '2023-11-29 13:56:30', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Habeeb Rahman logged-in successfully'),
(961, 79, 'Login', '2023-11-29 13:56:48', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(962, 57, 'Login', '2023-11-29 14:26:37', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Alen Cooper logged-in successfully'),
(963, 58, 'Login', '2023-11-29 14:27:05', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(964, 56, 'Login', '2023-11-29 14:27:48', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Habeeb Rahman logged-in successfully'),
(965, 58, 'Login', '2023-11-29 14:32:17', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(966, 93, 'Login', '2023-11-29 14:32:55', '2a02:4780:11::4f', 'User Cameron Hinton logged-in successfully'),
(967, 79, 'Login', '2023-11-29 14:35:52', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(968, 56, 'Login', '2023-11-29 14:42:50', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Habeeb Rahman logged-in successfully'),
(969, 58, 'Login', '2023-11-29 14:45:18', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(970, 93, 'Login', '2023-11-29 14:46:06', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Cameron Hinton logged-in successfully'),
(971, 56, 'Login', '2023-11-29 14:57:56', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Habeeb Rahman logged-in successfully'),
(972, 93, 'Login', '2023-11-29 14:58:43', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Cameron Hinton logged-in successfully'),
(973, 115, 'Logoff', '2023-11-29 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(974, 93, 'Login', '2023-11-29 15:02:49', '171.49.223.38', 'User Cameron Hinton logged-in successfully'),
(975, 93, 'Login', '2023-11-29 15:04:21', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Cameron Hinton logged-in successfully'),
(976, 56, 'Login', '2023-11-29 15:09:38', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Habeeb Rahman logged-in successfully'),
(977, 57, 'Logoff', '2023-11-29 17:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(978, 58, 'Logoff', '2023-11-29 17:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(979, 79, 'Logoff', '2023-11-29 17:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(980, 56, 'Logoff', '2023-11-29 18:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(981, 93, 'Logoff', '2023-11-29 18:00:05', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(982, 56, 'Login', '2023-11-30 04:46:22', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(983, 57, 'Login', '2023-11-30 04:51:21', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Alen Cooper logged-in successfully'),
(984, 58, 'Login', '2023-11-30 04:52:45', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(985, 58, 'Login', '2023-11-30 04:52:45', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(986, 108, 'Login', '2023-11-30 04:53:17', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Teacher Test logged-in successfully'),
(987, 108, 'Login', '2023-11-30 04:53:59', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Teacher Test logged-in successfully'),
(988, 56, 'Login', '2023-11-30 04:56:44', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(989, 57, 'Login', '2023-11-30 05:01:42', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Alen Cooper logged-in successfully'),
(990, 93, 'Login', '2023-11-30 05:03:13', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Cameron Hinton logged-in successfully'),
(991, 93, 'Login', '2023-11-30 05:03:16', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Cameron Hinton logged-in successfully'),
(992, 115, 'Login', '2023-11-30 05:03:49', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Genevieve Lambert logged-in successfully'),
(993, 58, 'Login', '2023-11-30 05:04:15', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(994, 56, 'Login', '2023-11-30 05:04:37', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(995, 71, 'Login', '2023-11-30 05:05:20', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Theodora Reynolds logged-in successfully'),
(996, 56, 'Login', '2023-11-30 05:09:38', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Habeeb Rahman logged-in successfully'),
(997, 57, 'Login', '2023-11-30 05:13:20', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Alen Cooper logged-in successfully'),
(998, 58, 'Login', '2023-11-30 05:13:41', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(999, 58, 'Login', '2023-11-30 05:16:13', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1000, 56, 'Login', '2023-11-30 05:17:58', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Habeeb Rahman logged-in successfully'),
(1001, 56, 'Login', '2023-11-30 05:39:44', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(1002, 56, 'Login', '2023-11-30 05:43:16', '171.49.223.38', 'User Habeeb Rahman logged-in successfully'),
(1003, 58, 'Login', '2023-11-30 05:44:01', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1004, 58, 'Login', '2023-11-30 05:44:08', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1005, 108, 'Login', '2023-11-30 05:44:48', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Teacher Test logged-in successfully'),
(1006, 56, 'Login', '2023-11-30 05:53:52', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(1007, 56, 'Login', '2023-11-30 05:54:34', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(1008, 79, 'Login', '2023-11-30 06:25:05', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1009, 79, 'Login', '2023-11-30 06:27:16', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1010, 79, 'Login', '2023-11-30 06:32:23', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1011, 56, 'Login', '2023-11-30 06:34:57', '171.49.223.38', 'User Habeeb Rahman logged-in successfully'),
(1012, 108, 'Login', '2023-11-30 06:36:25', '171.49.223.38', 'User Teacher Test logged-in successfully'),
(1013, 79, 'Login', '2023-11-30 06:38:33', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1014, 56, 'Login', '2023-11-30 06:48:35', '171.49.223.38', 'User Habeeb Rahman logged-in successfully'),
(1015, 79, 'Login', '2023-11-30 06:53:34', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1016, 93, 'Login', '2023-11-30 07:01:51', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Cameron Hinton imporsonated by Super Admin successfully'),
(1017, 79, 'Login', '2023-11-30 07:03:57', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1018, 79, 'Login', '2023-11-30 07:07:14', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1019, 58, 'Login', '2023-11-30 07:10:31', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1020, 79, 'Login', '2023-11-30 07:19:08', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1021, 57, 'Login', '2023-11-30 07:26:32', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Alen Cooper logged-in successfully'),
(1022, 79, 'Login', '2023-11-30 07:27:12', '117.222.161.205', 'User Super Admin logged-in successfully'),
(1023, 57, 'Login', '2023-11-30 07:33:18', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Alen Cooper logged-in successfully'),
(1024, 58, 'Login', '2023-11-30 07:39:30', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1025, 57, 'Login', '2023-11-30 07:47:35', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Alen Cooper logged-in successfully'),
(1026, 79, 'Login', '2023-11-30 07:57:31', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1027, 118, 'Login', '2023-11-30 07:58:46', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User amar akbar logged-in successfully'),
(1028, 71, 'Logoff', '2023-11-30 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1029, 96, 'Logoff', '2023-11-30 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1030, 115, 'Logoff', '2023-11-30 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1031, 79, 'Login', '2023-11-30 08:03:20', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User Super Admin logged-in successfully'),
(1032, 118, 'Login', '2023-11-30 08:03:49', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User amar akbar logged-in successfully'),
(1033, 79, 'Login', '2023-11-30 08:04:41', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User Super Admin logged-in successfully'),
(1034, 79, 'Login', '2023-11-30 08:23:16', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1035, 119, 'Login', '2023-11-30 08:28:37', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User new admin logged-in successfully'),
(1036, 79, 'Login', '2023-11-30 08:29:43', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User Super Admin logged-in successfully'),
(1037, 119, 'Login', '2023-11-30 08:30:19', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User new admin logged-in successfully'),
(1038, 120, 'Login', '2023-11-30 08:35:06', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User amar khan logged-in successfully'),
(1039, 79, 'Login', '2023-11-30 08:38:42', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User Super Admin logged-in successfully'),
(1040, 122, 'Login', '2023-11-30 08:49:43', '171.49.223.38', 'User jhon wick logged-in successfully'),
(1041, 79, 'Login', '2023-11-30 08:52:48', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User Super Admin logged-in successfully'),
(1042, 123, 'Login', '2023-11-30 08:54:15', '171.49.223.38', 'User jhon snow logged-in successfully'),
(1043, 123, 'Login', '2023-11-30 08:54:48', '171.49.223.38', 'User jhon snow logged-in successfully'),
(1044, 79, 'Login', '2023-11-30 08:55:17', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User Super Admin logged-in successfully'),
(1045, 123, 'Login', '2023-11-30 08:56:37', '2401:4900:1cdc:6f03:b832:c6bb:5c5e:67cd', 'User jhon snow logged-in successfully'),
(1046, 56, 'Logoff', '2023-11-30 09:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1047, 108, 'Logoff', '2023-11-30 09:00:05', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1048, 57, 'Logoff', '2023-11-30 10:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1049, 58, 'Logoff', '2023-11-30 10:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1050, 93, 'Logoff', '2023-11-30 10:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1051, 123, 'Login', '2023-11-30 10:19:53', '117.222.161.205', 'User jhon snow logged-in successfully'),
(1052, 79, 'Login', '2023-11-30 10:20:53', '117.222.161.205', 'User Super Admin logged-in successfully'),
(1053, 58, 'Login', '2023-11-30 10:26:36', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1054, 79, 'Login', '2023-11-30 10:27:21', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1055, 79, 'Login', '2023-11-30 10:27:22', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1056, 79, 'Login', '2023-11-30 10:30:01', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1057, 122, 'Login', '2023-11-30 10:36:37', '117.222.161.205', 'User jhon wick logged-in successfully'),
(1058, 79, 'Login', '2023-11-30 10:36:58', '117.222.161.205', 'User Super Admin logged-in successfully'),
(1059, 79, 'Login', '2023-11-30 10:38:24', '117.222.161.205', 'User Super Admin logged-in successfully'),
(1060, 125, 'Login', '2023-11-30 10:45:42', '2401:4900:1cdc:6f03:5016:ad79:2ef3:8925', 'User jhon doe logged-in successfully'),
(1061, 79, 'Login', '2023-11-30 10:46:12', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1062, 125, 'Login', '2023-11-30 10:47:29', '2401:4900:1cdc:6f03:5016:ad79:2ef3:8925', 'User jhon doe logged-in successfully'),
(1063, 125, 'Login', '2023-11-30 10:47:55', '171.49.223.38', 'User jhon doe logged-in successfully'),
(1064, 79, 'Login', '2023-11-30 10:48:05', '2401:4900:1cdc:6f03:5016:ad79:2ef3:8925', 'User Super Admin logged-in successfully'),
(1065, 58, 'Login', '2023-11-30 10:50:08', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1066, 125, 'Login', '2023-11-30 10:52:03', '2401:4900:1cdc:6f03:5016:ad79:2ef3:8925', 'User jhon doe logged-in successfully'),
(1067, 79, 'Login', '2023-11-30 10:53:16', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1068, 125, 'Login', '2023-11-30 10:54:22', '171.49.223.38', 'User jhon doe logged-in successfully'),
(1069, 79, 'Login', '2023-11-30 10:55:21', '2401:4900:1cdc:6f03:5016:ad79:2ef3:8925', 'User Super Admin logged-in successfully'),
(1070, 97, 'Logoff', '2023-11-30 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1071, 118, 'Logoff', '2023-11-30 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1072, 119, 'Logoff', '2023-11-30 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1073, 120, 'Logoff', '2023-11-30 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1074, 126, 'Login', '2023-11-30 11:06:13', '171.49.223.38', 'User penny carter logged-in successfully'),
(1075, 79, 'Login', '2023-11-30 11:09:05', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1076, 79, 'Login', '2023-11-30 11:18:02', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1077, 58, 'Login', '2023-11-30 11:23:52', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1078, 79, 'Login', '2023-11-30 11:29:25', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1079, 126, 'Login', '2023-11-30 11:32:16', '171.49.223.38', 'User penny carter logged-in successfully'),
(1080, 127, 'Login', '2023-11-30 11:32:53', '171.49.223.38', 'User sam woxx logged-in successfully'),
(1081, 127, 'Login', '2023-11-30 11:34:42', '171.49.223.38', 'User sam woxx logged-in successfully'),
(1082, 127, 'Login', '2023-11-30 11:36:10', '117.222.161.205', 'User sam woxx logged-in successfully'),
(1083, 57, 'Login', '2023-11-30 11:41:15', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Alen Cooper logged-in successfully'),
(1084, 58, 'Login', '2023-11-30 11:41:30', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User John Doe logged-in successfully'),
(1085, 58, 'Login', '2023-11-30 11:43:55', '171.49.223.38', 'User John Doe logged-in successfully'),
(1086, 71, 'Logoff', '2023-11-30 12:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1087, 79, 'Login', '2023-11-30 12:18:53', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Super Admin logged-in successfully'),
(1088, 79, 'Login', '2023-11-30 12:19:22', '2401:4900:1cdc:6f03:5016:ad79:2ef3:8925', 'User Super Admin logged-in successfully'),
(1089, 126, 'Login', '2023-11-30 12:31:45', '171.49.223.38', 'User penny carter logged-in successfully'),
(1090, 79, 'Login', '2023-11-30 12:33:30', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1091, 93, 'Login', '2023-11-30 12:35:16', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Cameron Hinton logged-in successfully'),
(1092, 79, 'Login', '2023-11-30 12:36:16', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Super Admin logged-in successfully'),
(1093, 69, 'Login', '2023-11-30 12:37:07', '2401:4900:1cdc:6f03:5016:ad79:2ef3:8925', 'User Ricky Kshlerin logged-in successfully'),
(1094, 120, 'Login', '2023-11-30 12:37:54', '171.49.223.38', 'User amar khan logged-in successfully'),
(1095, 57, 'Login', '2023-11-30 12:40:45', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Alen Cooper logged-in successfully'),
(1096, 79, 'Login', '2023-11-30 12:42:15', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Super Admin logged-in successfully'),
(1097, 79, 'Login', '2023-11-30 12:44:06', '2401:4900:1cdc:6f03:5016:ad79:2ef3:8925', 'User Super Admin logged-in successfully'),
(1098, 57, 'Login', '2023-11-30 12:47:56', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Alen Cooper logged-in successfully'),
(1099, 57, 'Login', '2023-11-30 12:56:02', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Alen Cooper logged-in successfully'),
(1100, 79, 'Login', '2023-11-30 12:56:28', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Super Admin logged-in successfully'),
(1101, 126, 'Login', '2023-11-30 12:58:44', '171.49.223.38', 'User penny carter logged-in successfully'),
(1102, 57, 'Login', '2023-11-30 12:59:43', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Alen Cooper logged-in successfully'),
(1103, 122, 'Logoff', '2023-11-30 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1104, 125, 'Logoff', '2023-11-30 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1105, 79, 'Login', '2023-11-30 13:02:41', '2401:4900:1cdc:6f03:c0b9:9e40:e953:a110', 'User Super Admin logged-in successfully'),
(1106, 57, 'Login', '2023-11-30 13:05:40', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Alen Cooper logged-in successfully'),
(1107, 79, 'Login', '2023-11-30 13:06:04', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Super Admin logged-in successfully'),
(1108, 57, 'Login', '2023-11-30 13:07:46', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Alen Cooper logged-in successfully'),
(1109, 79, 'Login', '2023-11-30 13:09:20', '2401:4900:1cdc:6f03:5016:ad79:2ef3:8925', 'User Super Admin logged-in successfully'),
(1110, 126, 'Login', '2023-11-30 13:10:20', '2401:4900:1cdc:6f03:5016:ad79:2ef3:8925', 'User penny carter logged-in successfully'),
(1111, 79, 'Login', '2023-11-30 13:11:05', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Super Admin logged-in successfully'),
(1112, 57, 'Login', '2023-11-30 13:12:14', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Alen Cooper logged-in successfully'),
(1113, 79, 'Login', '2023-11-30 13:15:11', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Super Admin logged-in successfully'),
(1114, 79, 'Login', '2023-11-30 13:19:09', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1115, 93, 'Login', '2023-11-30 13:25:41', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Cameron Hinton logged-in successfully'),
(1116, 79, 'Login', '2023-11-30 13:27:45', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Super Admin logged-in successfully'),
(1117, 58, 'Login', '2023-11-30 13:59:07', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User John Doe logged-in successfully'),
(1118, 127, 'Logoff', '2023-11-30 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1119, 79, 'Login', '2023-11-30 14:02:30', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Super Admin logged-in successfully'),
(1120, 79, 'Login', '2023-11-30 14:14:17', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1121, 79, 'Login', '2023-11-30 14:52:45', '171.49.223.38', 'User Super Admin logged-in successfully'),
(1122, 69, 'Logoff', '2023-11-30 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1123, 120, 'Logoff', '2023-11-30 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1124, 93, 'Login', '2023-11-30 15:04:11', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Cameron Hinton logged-in successfully'),
(1125, 79, 'Login', '2023-11-30 15:06:13', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Super Admin logged-in successfully'),
(1126, 79, 'Login', '2023-11-30 15:10:21', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Super Admin logged-in successfully'),
(1127, 56, 'Login', '2023-11-30 15:14:23', '49.37.226.196', 'User Habeeb Rahmank logged-in successfully'),
(1128, 57, 'Login', '2023-11-30 15:20:20', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Alen Cooper logged-in successfully'),
(1129, 79, 'Login', '2023-11-30 15:46:04', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Super Admin logged-in successfully'),
(1130, 108, 'Login', '2023-11-30 15:46:42', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Teacher Test logged-in successfully'),
(1131, 79, 'Login', '2023-11-30 15:47:19', '2401:4900:1cdc:6f03:f02c:d87d:7ff0:14e9', 'User Super Admin logged-in successfully'),
(1132, 79, 'Login', '2023-11-30 15:53:41', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1133, 58, 'Logoff', '2023-11-30 16:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1134, 126, 'Logoff', '2023-11-30 16:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1135, 79, 'Login', '2023-11-30 16:07:21', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1136, 79, 'Login', '2023-11-30 16:11:36', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1137, 57, 'Login', '2023-11-30 16:17:56', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Alen Cooper logged-in successfully'),
(1138, 58, 'Login', '2023-11-30 16:18:42', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1139, 57, 'Login', '2023-11-30 16:19:54', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Alen Cooper logged-in successfully'),
(1140, 79, 'Login', '2023-11-30 16:20:16', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1141, 79, 'Login', '2023-11-30 16:25:14', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1142, 79, 'Login', '2023-11-30 16:25:55', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1143, 79, 'Login', '2023-11-30 16:26:02', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1144, 79, 'Login', '2023-11-30 16:26:07', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1145, 79, 'Login', '2023-11-30 16:26:13', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1146, 79, 'Login', '2023-11-30 16:31:36', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Super Admin logged-in successfully'),
(1147, 79, 'Login', '2023-11-30 16:56:53', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1148, 63, 'Logoff', '2023-11-30 17:00:06', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1149, 79, 'Login', '2023-11-30 17:05:11', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1150, 56, 'Login', '2023-11-30 17:19:54', '49.37.226.196', 'User Habeeb Rahman logged-in successfully'),
(1151, 79, 'Login', '2023-11-30 17:22:34', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1152, 56, 'Login', '2023-11-30 17:33:53', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1153, 56, 'Login', '2023-11-30 17:34:09', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(1154, 56, 'Login', '2023-11-30 17:45:06', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1155, 79, 'Login', '2023-11-30 17:45:35', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1156, 93, 'Login', '2023-11-30 17:46:22', '2a02:4780:11::4f', 'User Cameron Hinton imporsonated by Super Admin successfully'),
(1157, 93, 'Login', '2023-11-30 17:46:54', '2a02:4780:11::4f', 'User Cameron Hinton logged-in successfully'),
(1158, 108, 'Logoff', '2023-11-30 18:00:07', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1159, 79, 'Login', '2023-11-30 18:17:08', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1160, 79, 'Login', '2023-11-30 18:24:10', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1161, 57, 'Login', '2023-11-30 18:34:02', '49.37.226.196', 'User Alen Cooper logged-in successfully'),
(1162, 58, 'Login', '2023-11-30 18:35:05', '49.37.226.196', 'User John Doe logged-in successfully'),
(1163, 58, 'Login', '2023-11-30 18:38:28', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1164, 56, 'Login', '2023-11-30 19:02:41', '49.37.226.196', 'User Habeeb Rahman logged-in successfully'),
(1165, 93, 'Logoff', '2023-11-30 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1166, 57, 'Logoff', '2023-11-30 21:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1167, 58, 'Logoff', '2023-11-30 21:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1168, 79, 'Logoff', '2023-11-30 21:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1169, 56, 'Logoff', '2023-11-30 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1170, 56, 'Login', '2023-12-01 03:23:06', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1171, 56, 'Logoff', '2023-12-01 06:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1172, 58, 'Login', '2023-12-01 16:44:48', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1173, 56, 'Login', '2023-12-01 17:42:15', '49.37.226.205', 'User Habeeb Rahman logged-in successfully'),
(1174, 58, 'Login', '2023-12-01 17:43:28', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1175, 56, 'Login', '2023-12-01 18:12:08', '49.37.226.205', 'User Habeeb Rahman logged-in successfully'),
(1176, 58, 'Login', '2023-12-01 18:21:09', '2405:201:f002:88ea:246e:e29:1e5f:7862', 'User John Doe logged-in successfully'),
(1177, 56, 'Login', '2023-12-01 18:36:28', '49.37.226.205', 'User Habeeb Rahman logged-in successfully'),
(1178, 56, 'Login', '2023-12-01 19:10:34', '49.37.226.205', 'User Habeeb Rahman logged-in successfully'),
(1179, 58, 'Logoff', '2023-12-01 21:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1180, 56, 'Logoff', '2023-12-01 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1181, 93, 'Login', '2023-12-02 08:15:14', '2a02:4780:11::4f', 'User Cameron Hinton logged-in successfully'),
(1182, 56, 'Login', '2023-12-02 08:20:40', '171.49.223.38', 'User Habeeb Rahman logged-in successfully'),
(1183, 56, 'Login', '2023-12-02 09:06:42', '171.49.223.38', 'User Habeeb Rahman logged-in successfully'),
(1184, 79, 'Login', '2023-12-02 09:28:59', '157.44.197.31', 'User Super Admin logged-in successfully'),
(1185, 57, 'Login', '2023-12-02 09:31:21', '2409:4073:10f:b424::2125:ad', 'User Alen Cooper logged-in successfully'),
(1186, 57, 'Login', '2023-12-02 09:31:41', '157.44.200.108', 'User Alen Cooper logged-in successfully'),
(1187, 58, 'Login', '2023-12-02 09:32:17', '157.44.200.108', 'User John Doe logged-in successfully'),
(1188, 108, 'Login', '2023-12-02 09:32:56', '157.44.200.108', 'User Teacher Test logged-in successfully'),
(1189, 79, 'Login', '2023-12-02 09:33:35', '157.44.200.108', 'User Super Admin logged-in successfully'),
(1190, 120, 'Login', '2023-12-02 10:29:46', '157.44.222.247', 'User amar khan logged-in successfully'),
(1191, 79, 'Login', '2023-12-02 10:31:09', '157.44.222.247', 'User Super Admin logged-in successfully'),
(1192, 140, 'Login', '2023-12-02 10:33:04', '157.44.222.247', 'User marcopolo jhon logged-in successfully'),
(1193, 79, 'Login', '2023-12-02 10:36:14', '157.44.222.247', 'User Super Admin logged-in successfully'),
(1194, 141, 'Login', '2023-12-02 10:48:15', '157.44.222.247', 'User polo marco logged-in successfully'),
(1195, 143, 'Login', '2023-12-02 10:50:59', '2409:4073:10f:b424::2125:ad', 'User alex martin logged-in successfully'),
(1196, 79, 'Login', '2023-12-02 10:51:18', '157.44.222.247', 'User Super Admin logged-in successfully'),
(1197, 79, 'Login', '2023-12-02 10:52:02', '157.44.222.247', 'User Super Admin logged-in successfully'),
(1198, 93, 'Logoff', '2023-12-02 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1199, 93, 'Login', '2023-12-02 11:07:36', '171.49.223.38', 'User Cameron Hinton logged-in successfully'),
(1200, 79, 'Login', '2023-12-02 11:13:43', '2401:4900:1cdc:6f03:f809:1723:d075:7c3f', 'User Super Admin logged-in successfully'),
(1201, 56, 'Logoff', '2023-12-02 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1202, 57, 'Logoff', '2023-12-02 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1203, 58, 'Logoff', '2023-12-02 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1204, 108, 'Logoff', '2023-12-02 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1205, 120, 'Logoff', '2023-12-02 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1206, 140, 'Logoff', '2023-12-02 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1207, 141, 'Logoff', '2023-12-02 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1208, 143, 'Logoff', '2023-12-02 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1209, 79, 'Logoff', '2023-12-02 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1210, 93, 'Logoff', '2023-12-02 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1211, 63, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1212, 69, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1213, 71, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1214, 96, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1215, 97, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1216, 115, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1217, 118, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1218, 119, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1219, 122, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1220, 125, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1221, 126, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1222, 127, 'Update profile', '2023-12-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1223, 79, 'Login', '2023-12-03 06:03:58', '27.63.212.134', 'User Super Admin logged-in successfully'),
(1224, 56, 'Login', '2023-12-03 06:53:21', '58.178.56.87', 'User Habeeb Rahman logged-in successfully'),
(1225, 56, 'Logoff', '2023-12-03 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1226, 79, 'Logoff', '2023-12-03 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1227, 56, 'Login', '2023-12-03 13:02:00', '58.178.56.87', 'User Habeeb Rahman logged-in successfully'),
(1228, 56, 'Login', '2023-12-03 15:21:00', '103.181.40.53', 'User Habeeb Rahman logged-in successfully'),
(1229, 79, 'Login', '2023-12-03 15:30:49', '103.181.40.53', 'User Super Admin logged-in successfully'),
(1230, 56, 'Login', '2023-12-03 15:31:59', '103.181.40.53', 'User Habeeb Rahman logged-in successfully'),
(1231, 56, 'Login', '2023-12-03 15:38:51', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1232, 56, 'Logoff', '2023-12-03 18:00:06', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1233, 79, 'Logoff', '2023-12-03 18:00:07', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1234, 79, 'Login', '2023-12-03 18:18:13', '103.181.40.53', 'User Super Admin logged-in successfully'),
(1235, 56, 'Login', '2023-12-03 18:19:02', '103.181.40.53', 'User Habeeb Rahman logged-in successfully'),
(1236, 56, 'Login', '2023-12-03 20:45:42', '103.181.40.53', 'User Habeeb Rahman logged-in successfully'),
(1237, 79, 'Logoff', '2023-12-03 21:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1238, 56, 'Logoff', '2023-12-03 23:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1239, 56, 'Login', '2023-12-04 05:47:59', '120.17.144.49', 'User Habeeb Rahman logged-in successfully'),
(1240, 56, 'Logoff', '2023-12-04 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1241, 79, 'Login', '2023-12-04 09:09:33', '2401:4900:1cdc:2112:f809:1723:d075:7c3f', 'User Super Admin logged-in successfully'),
(1242, 79, 'Login', '2023-12-04 09:24:08', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1243, 79, 'Logoff', '2023-12-04 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1244, 57, 'Update profile', '2023-12-05 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1245, 58, 'Update profile', '2023-12-05 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1246, 93, 'Update profile', '2023-12-05 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1247, 108, 'Update profile', '2023-12-05 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1248, 120, 'Update profile', '2023-12-05 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1249, 140, 'Update profile', '2023-12-05 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1250, 141, 'Update profile', '2023-12-05 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1251, 143, 'Update profile', '2023-12-05 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1252, 79, 'Login', '2023-12-05 04:42:24', '117.208.31.196', 'User Super Admin logged-in successfully'),
(1253, 79, 'Login', '2023-12-05 06:33:50', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1254, 79, 'Logoff', '2023-12-05 09:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1255, 56, 'Login', '2023-12-05 15:30:10', '49.37.227.14', 'User Habeeb Rahman logged-in successfully'),
(1256, 57, 'Login', '2023-12-05 16:08:42', '49.37.227.14', 'User Alen Cooper logged-in successfully'),
(1257, 58, 'Login', '2023-12-05 16:09:08', '49.37.227.14', 'User John Doe logged-in successfully'),
(1258, 56, 'Login', '2023-12-05 16:13:43', '49.37.227.14', 'User Habeeb Rahman logged-in successfully'),
(1259, 57, 'Login', '2023-12-05 16:19:25', '2401:4900:6158:2e:44f0:e266:873c:d699', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(1260, 56, 'Login', '2023-12-05 16:20:17', '2401:4900:6158:2e:44f0:e266:873c:d699', 'User Habeeb Rahman logged-in successfully'),
(1261, 58, 'Login', '2023-12-05 16:20:34', '2401:4900:6158:2e:44f0:e266:873c:d699', 'User John Doe imporsonated by Habeeb Rahman successfully'),
(1262, 56, 'Login', '2023-12-05 16:36:20', '27.63.232.22', 'User Habeeb Rahman logged-in successfully'),
(1263, 56, 'Logoff', '2023-12-05 19:00:06', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1264, 57, 'Logoff', '2023-12-05 19:00:07', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1265, 58, 'Logoff', '2023-12-05 19:00:07', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1266, 79, 'Login', '2023-12-06 08:37:06', '27.63.212.139', 'User Super Admin logged-in successfully'),
(1267, 72, 'Login', '2023-12-06 08:41:56', '117.252.208.22', 'User Onie Goldner imporsonated by Super Admin successfully'),
(1268, 93, 'Login', '2023-12-06 09:20:16', '117.252.208.22', 'User Cameron Hinton logged-in successfully'),
(1269, 79, 'Login', '2023-12-06 09:28:33', '117.252.208.22', 'User Super Admin logged-in successfully'),
(1270, 75, 'Login', '2023-12-06 09:29:56', '117.252.208.22', 'User Dominique Clements imporsonated by Super Admin successfully'),
(1271, 79, 'Login', '2023-12-06 09:31:32', '117.252.208.22', 'User Super Admin logged-in successfully'),
(1272, 80, 'Login', '2023-12-06 09:34:07', '117.252.208.22', 'User Alana Valenzuela imporsonated by Super Admin successfully'),
(1273, 79, 'Login', '2023-12-06 09:49:02', '117.252.208.22', 'User Super Admin logged-in successfully'),
(1274, 82, 'Login', '2023-12-06 09:49:39', '117.252.208.22', 'User Reese Haynes imporsonated by Super Admin successfully'),
(1275, 93, 'Login', '2023-12-06 10:05:50', '2a02:4780:11::4f', 'User Cameron Hinton logged-in successfully'),
(1276, 56, 'Login', '2023-12-06 10:23:54', '103.141.55.234', 'User Habeeb Rahman logged-in successfully'),
(1277, 57, 'Logoff', '2023-12-06 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1278, 58, 'Logoff', '2023-12-06 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1279, 72, 'Logoff', '2023-12-06 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1280, 79, 'Login', '2023-12-06 11:39:55', '117.252.208.22', 'User Super Admin logged-in successfully'),
(1281, 93, 'Login', '2023-12-06 11:56:59', '117.252.208.22', 'User Cameron Hinton logged-in successfully'),
(1282, 75, 'Logoff', '2023-12-06 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1283, 80, 'Logoff', '2023-12-06 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1284, 82, 'Logoff', '2023-12-06 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1285, 79, 'Login', '2023-12-06 12:08:30', '117.252.208.22', 'User Super Admin logged-in successfully'),
(1286, 79, 'Login', '2023-12-06 12:12:11', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1287, 75, 'Login', '2023-12-06 12:28:46', '117.252.208.22', 'User Dominique Clements imporsonated by Super Admin successfully'),
(1288, 56, 'Logoff', '2023-12-06 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1289, 115, 'Logoff', '2023-12-06 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1290, 93, 'Login', '2023-12-06 13:19:32', '117.252.208.22', 'User Cameron Hinton logged-in successfully'),
(1291, 79, 'Login', '2023-12-06 13:21:55', '117.252.208.22', 'User Super Admin logged-in successfully'),
(1292, 93, 'Login', '2023-12-06 13:29:09', '117.252.208.22', 'User Cameron Hinton logged-in successfully'),
(1293, 75, 'Logoff', '2023-12-06 15:00:05', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1294, 115, 'Logoff', '2023-12-06 15:00:05', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1295, 79, 'Logoff', '2023-12-06 16:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1296, 93, 'Logoff', '2023-12-06 16:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1297, 56, 'Login', '2023-12-06 17:23:31', '49.37.225.113', 'User Habeeb Rahman logged-in successfully'),
(1298, 56, 'Login', '2023-12-06 17:24:17', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1299, 79, 'Login', '2023-12-06 17:29:56', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1300, 58, 'Login', '2023-12-06 17:51:45', '49.37.225.113', 'User John Doe logged-in successfully'),
(1301, 56, 'Login', '2023-12-06 17:53:48', '49.37.225.113', 'User Habeeb Rahman logged-in successfully'),
(1302, 58, 'Login', '2023-12-06 18:29:36', '49.37.225.113', 'User John Doe logged-in successfully'),
(1303, 57, 'Logoff', '2023-12-06 19:00:06', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1304, 56, 'Login', '2023-12-06 19:00:40', '49.37.225.113', 'User Habeeb Rahman logged-in successfully'),
(1305, 56, 'Login', '2023-12-06 19:00:42', '49.37.225.113', 'User Habeeb Rahman logged-in successfully'),
(1306, 58, 'Login', '2023-12-06 19:06:23', '49.37.225.113', 'User John Doe logged-in successfully'),
(1307, 79, 'Login', '2023-12-06 19:12:10', '117.242.76.169', 'User Super Admin logged-in successfully'),
(1308, 93, 'Login', '2023-12-06 19:13:14', '117.242.76.169', 'User Cameron Hinton logged-in successfully'),
(1309, 79, 'Login', '2023-12-06 19:14:52', '117.242.76.169', 'User Super Admin logged-in successfully'),
(1310, 56, 'Logoff', '2023-12-06 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1311, 58, 'Logoff', '2023-12-06 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1312, 79, 'Logoff', '2023-12-06 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1313, 93, 'Logoff', '2023-12-06 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1314, 56, 'Login', '2023-12-06 22:06:04', '120.18.84.201', 'User Habeeb Rahman logged-in successfully'),
(1315, 56, 'Logoff', '2023-12-07 01:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1316, 56, 'Login', '2023-12-07 06:44:12', '117.242.76.169', 'User Habeeb Rahman logged-in successfully'),
(1317, 56, 'Logoff', '2023-12-07 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1318, 56, 'Login', '2023-12-07 17:08:37', '49.37.225.113', 'User Habeeb Rahman logged-in successfully'),
(1319, 57, 'Login', '2023-12-07 17:15:32', '49.37.225.113', 'User Alen Cooper logged-in successfully'),
(1320, 56, 'Logoff', '2023-12-07 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1321, 57, 'Logoff', '2023-12-07 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1322, 58, 'Update profile', '2023-12-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1323, 75, 'Update profile', '2023-12-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1324, 79, 'Update profile', '2023-12-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1325, 80, 'Update profile', '2023-12-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1326, 82, 'Update profile', '2023-12-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1327, 93, 'Update profile', '2023-12-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1328, 115, 'Update profile', '2023-12-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1329, 56, 'Update profile', '2023-12-10 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1330, 57, 'Update profile', '2023-12-10 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1331, 79, 'Login', '2023-12-11 05:36:56', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1332, 147, 'Login', '2023-12-11 06:09:54', '2a02:4780:11::4f', 'User Franowner Missouri imporsonated by Super Admin successfully'),
(1333, 79, 'Login', '2023-12-11 06:29:13', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1334, 79, 'Login', '2023-12-11 06:41:58', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1335, 79, 'Login', '2023-12-11 06:43:10', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1336, 79, 'Login', '2023-12-11 06:47:02', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1337, 56, 'Login', '2023-12-11 06:56:59', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1338, 79, 'Login', '2023-12-11 06:58:51', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1339, 56, 'Login', '2023-12-11 07:00:48', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1340, 75, 'Login', '2023-12-11 07:01:32', '2a02:4780:11::4f', 'User Dominique Clements imporsonated by Super Admin successfully'),
(1341, 106, 'Login', '2023-12-11 07:01:43', '2a02:4780:11::4f', 'User Derik Abraham imporsonated by Habeeb Rahman successfully'),
(1342, 79, 'Login', '2023-12-11 07:02:35', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1343, 80, 'Login', '2023-12-11 07:03:10', '2a02:4780:11::4f', 'User Alana Valenzuela imporsonated by Super Admin successfully'),
(1344, 108, 'Login', '2023-12-11 07:04:08', '2a02:4780:11::4f', 'User Teacher Test logged-in successfully'),
(1345, 56, 'Login', '2023-12-11 07:14:40', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1346, 57, 'Login', '2023-12-11 07:15:40', '2a02:4780:11::4f', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(1347, 79, 'Login', '2023-12-11 07:24:30', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1348, 147, 'Login', '2023-12-11 07:26:37', '2a02:4780:11::4f', 'User Franowner Missouri imporsonated by Super Admin successfully');
INSERT INTO `tbl_user_login_audit` (`userLoginAuditId`, `userProfileId`, `action`, `actionDateTime`, `deviceId`, `comments`) VALUES
(1349, 79, 'Login', '2023-12-11 07:38:40', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1350, 148, 'Login', '2023-12-11 07:39:09', '2a02:4780:11::4f', 'User Missouri Teacher imporsonated by Super Admin successfully'),
(1351, 79, 'Login', '2023-12-11 07:39:56', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1352, 80, 'Login', '2023-12-11 07:52:23', '2a02:4780:11::4f', 'User Alana Valenzuela imporsonated by Super Admin successfully'),
(1353, 79, 'Login', '2023-12-11 07:57:29', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1354, 79, 'Login', '2023-12-11 08:00:14', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1355, 56, 'Logoff', '2023-12-11 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1356, 57, 'Logoff', '2023-12-11 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1357, 75, 'Logoff', '2023-12-11 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1358, 80, 'Logoff', '2023-12-11 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1359, 106, 'Logoff', '2023-12-11 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1360, 108, 'Logoff', '2023-12-11 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1361, 147, 'Logoff', '2023-12-11 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1362, 148, 'Logoff', '2023-12-11 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1363, 56, 'Login', '2023-12-11 10:56:55', '2401:4900:2629:6def:c029:42c8:c86c:136f', 'User Habeeb Rahman logged-in successfully'),
(1364, 58, 'Login', '2023-12-11 10:57:35', '106.203.78.163', 'User John Doe imporsonated by Habeeb Rahman successfully'),
(1365, 79, 'Logoff', '2023-12-11 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1366, 79, 'Login', '2023-12-11 11:21:45', '92.97.99.58', 'User Super Admin logged-in successfully'),
(1367, 56, 'Logoff', '2023-12-11 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1368, 58, 'Logoff', '2023-12-11 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1369, 80, 'Login', '2023-12-11 13:37:03', '92.97.99.58', 'User Alana Valenzuela imporsonated by Super Admin successfully'),
(1370, 79, 'Logoff', '2023-12-11 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1371, 80, 'Logoff', '2023-12-11 16:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1372, 56, 'Login', '2023-12-11 16:29:50', '49.37.225.91', 'User Habeeb Rahman logged-in successfully'),
(1373, 56, 'Login', '2023-12-11 16:31:09', '49.37.225.91', 'User Habeeb Rahman logged-in successfully'),
(1374, 58, 'Login', '2023-12-11 16:31:40', '49.37.225.91', 'User John Doe imporsonated by Habeeb Rahman successfully'),
(1375, 56, 'Login', '2023-12-11 16:56:47', '49.37.225.91', 'User Habeeb Rahman logged-in successfully'),
(1376, 93, 'Login', '2023-12-11 18:42:25', '106.203.73.67', 'User Cameron Hinton logged-in successfully'),
(1377, 56, 'Logoff', '2023-12-11 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1378, 58, 'Logoff', '2023-12-11 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1379, 93, 'Logoff', '2023-12-11 21:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1380, 79, 'Login', '2023-12-12 07:17:12', '92.97.99.58', 'User Super Admin logged-in successfully'),
(1381, 79, 'Logoff', '2023-12-12 10:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1382, 56, 'Login', '2023-12-12 13:07:37', '223.228.143.77', 'User Habeeb Rahman logged-in successfully'),
(1383, 56, 'Logoff', '2023-12-12 16:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1384, 79, 'Login', '2023-12-12 17:12:42', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1385, 153, 'Login', '2023-12-12 17:20:33', '2a02:4780:11::4f', 'User Bruce Wayne imporsonated by Super Admin successfully'),
(1386, 79, 'Login', '2023-12-12 17:24:20', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1387, 154, 'Login', '2023-12-12 17:29:34', '2a02:4780:11::4f', 'User Gotham Teacher imporsonated by Super Admin successfully'),
(1388, 79, 'Logoff', '2023-12-12 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1389, 153, 'Logoff', '2023-12-12 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1390, 154, 'Logoff', '2023-12-12 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1391, 79, 'Login', '2023-12-13 05:55:36', '92.97.99.58', 'User Super Admin logged-in successfully'),
(1392, 154, 'Login', '2023-12-13 05:56:00', '92.97.99.58', 'User Gotham Teacher imporsonated by Super Admin successfully'),
(1393, 79, 'Logoff', '2023-12-13 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1394, 154, 'Logoff', '2023-12-13 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1395, 79, 'Login', '2023-12-13 15:15:36', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1396, 79, 'Logoff', '2023-12-13 18:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1397, 57, 'Update profile', '2023-12-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1398, 58, 'Update profile', '2023-12-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1399, 75, 'Update profile', '2023-12-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1400, 80, 'Update profile', '2023-12-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1401, 93, 'Update profile', '2023-12-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1402, 106, 'Update profile', '2023-12-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1403, 108, 'Update profile', '2023-12-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1404, 147, 'Update profile', '2023-12-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1405, 148, 'Update profile', '2023-12-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1406, 56, 'Login', '2023-12-14 10:23:07', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1407, 56, 'Login', '2023-12-14 10:24:10', '120.18.203.194', 'User Habeeb Rahman logged-in successfully'),
(1408, 56, 'Logoff', '2023-12-14 13:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1409, 153, 'Update profile', '2023-12-15 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1410, 79, 'Update profile', '2023-12-16 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1411, 154, 'Update profile', '2023-12-16 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1412, 56, 'Update profile', '2023-12-17 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1413, 79, 'Login', '2023-12-18 08:16:48', '2.51.91.32', 'User Super Admin logged-in successfully'),
(1414, 154, 'Login', '2023-12-18 08:17:40', '2.51.91.32', 'User Gotham Teacher imporsonated by Super Admin successfully'),
(1415, 79, 'Logoff', '2023-12-18 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1416, 154, 'Logoff', '2023-12-18 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1417, 79, 'Login', '2023-12-18 12:07:30', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1418, 79, 'Logoff', '2023-12-18 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1419, 79, 'Login', '2023-12-18 18:03:08', '94.205.8.25', 'User Super Admin logged-in successfully'),
(1420, 79, 'Logoff', '2023-12-18 21:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1421, 56, 'Login', '2023-12-19 03:51:50', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1422, 56, 'Logoff', '2023-12-19 06:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1423, 79, 'Update profile', '2023-12-21 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1424, 154, 'Update profile', '2023-12-21 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1425, 79, 'Login', '2023-12-21 07:48:47', '2.51.91.32', 'User Super Admin logged-in successfully'),
(1426, 79, 'Login', '2023-12-21 07:53:09', '31.219.39.201', 'User Super Admin logged-in successfully'),
(1427, 79, 'Logoff', '2023-12-21 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1428, 56, 'Update profile', '2023-12-22 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1429, 79, 'Update profile', '2023-12-24 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1430, 56, 'Login', '2023-12-26 09:46:46', '110.225.157.179', 'User Habeeb Rahman logged-in successfully'),
(1431, 56, 'Logoff', '2023-12-26 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1432, 56, 'Login', '2023-12-27 02:48:24', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(1433, 56, 'Logoff', '2023-12-27 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1434, 56, 'Login', '2023-12-28 06:18:44', '58.178.56.87', 'User Habeeb Rahman logged-in successfully'),
(1435, 56, 'Logoff', '2023-12-28 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1436, 56, 'Login', '2023-12-28 15:40:27', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(1437, 56, 'Login', '2023-12-28 16:12:27', '137.97.116.120', 'User Habeeb Rahman logged-in successfully'),
(1438, 56, 'Logoff', '2023-12-28 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1439, 56, 'Login', '2023-12-29 04:49:48', '137.97.126.45', 'User Habeeb Rahman logged-in successfully'),
(1440, 56, 'Login', '2023-12-29 04:58:03', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(1441, 56, 'Logoff', '2023-12-29 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1442, 56, 'Update profile', '2024-01-01 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1443, 58, 'Login', '2024-01-02 05:14:24', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1444, 58, 'Logoff', '2024-01-02 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1445, 56, 'Login', '2024-01-02 09:18:14', '59.182.137.199', 'User Habeeb Rahman logged-in successfully'),
(1446, 56, 'Logoff', '2024-01-02 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1447, 58, 'Login', '2024-01-03 08:22:36', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1448, 58, 'Logoff', '2024-01-03 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1449, 56, 'Update profile', '2024-01-05 00:00:01', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1450, 56, 'Login', '2024-01-05 09:37:48', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1451, 56, 'Logoff', '2024-01-05 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1452, 58, 'Login', '2024-01-05 17:04:14', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1453, 58, 'Login', '2024-01-05 17:04:21', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1454, 58, 'Login', '2024-01-05 17:18:15', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1455, 58, 'Logoff', '2024-01-05 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1456, 58, 'Login', '2024-01-06 08:26:16', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User John Doe logged-in successfully'),
(1457, 58, 'Logoff', '2024-01-06 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1458, 56, 'Login', '2024-01-07 05:37:57', '2600:1f18:2424:8300:7e86:22ef:71eb:a74f', 'User Habeeb Rahman logged-in successfully'),
(1459, 56, 'Logoff', '2024-01-07 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1460, 58, 'Update profile', '2024-01-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1461, 58, 'Login', '2024-01-09 05:21:12', '2600:1f18:2424:8300:2ef1:51c8:3cb2:2662', 'User John Doe logged-in successfully'),
(1462, 58, 'Logoff', '2024-01-09 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1463, 56, 'Update profile', '2024-01-10 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1464, 79, 'Login', '2024-01-10 01:33:50', '2600:1f18:2424:8300:2ef1:51c8:3cb2:2662', 'User Super Admin logged-in successfully'),
(1465, 79, 'Logoff', '2024-01-10 04:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1466, 79, 'Login', '2024-01-11 04:34:41', '2600:1f18:2424:8300:2ef1:51c8:3cb2:2662', 'User Super Admin logged-in successfully'),
(1467, 79, 'Logoff', '2024-01-11 07:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1468, 58, 'Update profile', '2024-01-12 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1469, 79, 'Update profile', '2024-01-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1470, 79, 'Login', '2024-01-16 05:34:12', '2401:4900:1cde:4e2:8c07:9dd4:808b:f354', 'User Super Admin logged-in successfully'),
(1471, 79, 'Logoff', '2024-01-16 08:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1472, 79, 'Update profile', '2024-01-19 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1473, 56, 'Login', '2024-01-23 07:15:22', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1474, 56, 'Logoff', '2024-01-23 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1475, 56, 'Login', '2024-01-23 14:37:59', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1476, 56, 'Logoff', '2024-01-23 17:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1477, 56, 'Update profile', '2024-01-26 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1478, 79, 'Login', '2024-02-10 07:18:00', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1479, 79, 'Logoff', '2024-02-10 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1480, 56, 'Login', '2024-02-11 22:48:11', '1.145.72.242', 'User Habeeb Rahman logged-in successfully'),
(1481, 56, 'Logoff', '2024-02-12 01:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1482, 79, 'Update profile', '2024-02-13 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1483, 56, 'Login', '2024-02-13 01:14:23', '58.178.56.87', 'User Habeeb Rahman logged-in successfully'),
(1484, 56, 'Logoff', '2024-02-13 04:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1485, 56, 'Login', '2024-02-13 23:07:38', '1.145.76.110', 'User Habeeb Rahman logged-in successfully'),
(1486, 56, 'Logoff', '2024-02-14 02:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1487, 79, 'Login', '2024-02-14 06:27:21', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1488, 94, 'Login', '2024-02-14 06:42:43', '2a02:4780:11::4f', 'User Alexis Sawyer logged-in successfully'),
(1489, 79, 'Login', '2024-02-14 06:50:31', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1490, 79, 'Logoff', '2024-02-14 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1491, 94, 'Logoff', '2024-02-14 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1492, 79, 'Login', '2024-02-15 13:48:35', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1493, 79, 'Login', '2024-02-15 13:50:48', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1494, 79, 'Login', '2024-02-15 13:50:59', '2401:4900:1cde:b0be:8df2:32d:7ce0:33bb', 'User Super Admin logged-in successfully'),
(1495, 156, 'Login', '2024-02-15 13:57:25', '223.190.218.203', 'User confo manager logged-in successfully'),
(1496, 79, 'Login', '2024-02-15 13:59:08', '223.190.218.203', 'User Super Admin logged-in successfully'),
(1497, 75, 'Logoff', '2024-02-15 14:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1498, 156, 'Login', '2024-02-15 14:00:11', '223.190.218.203', 'User confo manager imporsonated by Super Admin successfully'),
(1499, 157, 'Login', '2024-02-15 14:01:25', '223.190.218.203', 'User confo1 teacher logged-in successfully'),
(1500, 156, 'Login', '2024-02-15 14:03:51', '2a02:4780:11::4f', 'User confo manager imporsonated by Super Admin successfully'),
(1501, 157, 'Login', '2024-02-15 14:05:22', '2a02:4780:11::4f', 'User confo1 teacher logged-in successfully'),
(1502, 79, 'Login', '2024-02-15 14:11:29', '106.205.165.1', 'User Super Admin logged-in successfully'),
(1503, 79, 'Login', '2024-02-15 14:13:14', '2401:4900:668a:ff08:c353:df04:3007:b7f4', 'User Super Admin logged-in successfully'),
(1504, 79, 'Login', '2024-02-15 14:23:49', '2401:4900:1cde:b0be:8df2:32d:7ce0:33bb', 'User Super Admin logged-in successfully'),
(1505, 79, 'Login', '2024-02-15 15:21:46', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1506, 156, 'Logoff', '2024-02-15 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1507, 157, 'Logoff', '2024-02-15 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1508, 79, 'Logoff', '2024-02-15 18:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1509, 79, 'Login', '2024-02-15 18:53:59', '49.37.226.66', 'User Super Admin logged-in successfully'),
(1510, 79, 'Login', '2024-02-15 18:56:19', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1511, 82, 'Logoff', '2024-02-15 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1512, 116, 'Login', '2024-02-15 19:03:29', '49.37.226.66', 'User Rahim Daniel logged-in successfully'),
(1513, 116, 'Login', '2024-02-15 19:03:29', '49.37.226.66', 'User Rahim Daniel logged-in successfully'),
(1514, 116, 'Login', '2024-02-15 19:06:25', '2401:4900:1cde:b0be:8df2:32d:7ce0:33bb', 'User Rahim Daniel logged-in successfully'),
(1515, 79, 'Login', '2024-02-15 19:07:23', '2401:4900:1cde:b0be:8df2:32d:7ce0:33bb', 'User Super Admin logged-in successfully'),
(1516, 82, 'Login', '2024-02-15 19:07:44', '223.190.218.203', 'User Reese Haynes imporsonated by Super Admin successfully'),
(1517, 79, 'Logoff', '2024-02-15 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1518, 82, 'Logoff', '2024-02-15 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1519, 116, 'Logoff', '2024-02-15 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1520, 79, 'Login', '2024-02-16 05:49:02', '117.216.144.182', 'User Super Admin logged-in successfully'),
(1521, 159, 'Login', '2024-02-16 06:11:14', '117.216.144.182', 'User Confo Manager logged-in successfully'),
(1522, 79, 'Login', '2024-02-16 06:12:02', '117.216.144.182', 'User Super Admin logged-in successfully'),
(1523, 159, 'Login', '2024-02-16 06:12:45', '117.216.144.182', 'User Confo Manager imporsonated by Super Admin successfully'),
(1524, 160, 'Login', '2024-02-16 06:14:52', '117.216.144.182', 'User Confo Teacher 1 logged-in successfully'),
(1525, 79, 'Logoff', '2024-02-16 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1526, 159, 'Logoff', '2024-02-16 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1527, 160, 'Logoff', '2024-02-16 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1528, 79, 'Login', '2024-02-16 11:05:13', '202.88.246.56', 'User Super Admin logged-in successfully'),
(1529, 79, 'Logoff', '2024-02-16 14:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1530, 56, 'Update profile', '2024-02-17 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1531, 94, 'Update profile', '2024-02-17 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1532, 79, 'Login', '2024-02-17 06:34:10', '223.185.204.17', 'User Super Admin logged-in successfully'),
(1533, 79, 'Logoff', '2024-02-17 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1534, 79, 'Login', '2024-02-17 19:28:50', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1535, 75, 'Login', '2024-02-17 19:34:58', '2a02:4780:11::4f', 'User Dominique Clements logged-in successfully'),
(1536, 79, 'Login', '2024-02-17 21:58:14', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1537, 75, 'Logoff', '2024-02-17 22:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1538, 79, 'Login', '2024-02-17 22:01:39', '206.169.137.201', 'User Super Admin logged-in successfully'),
(1539, 79, 'Login', '2024-02-17 22:13:28', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1540, 153, 'Login', '2024-02-17 22:21:00', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1541, 154, 'Login', '2024-02-17 22:26:46', '2a02:4780:11::4f', 'User Tim Walker logged-in successfully'),
(1542, 153, 'Login', '2024-02-17 22:27:47', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1543, 79, 'Login', '2024-02-17 22:35:42', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1544, 154, 'Login', '2024-02-17 22:38:33', '206.169.137.201', 'User Tim Walker logged-in successfully'),
(1545, 153, 'Login', '2024-02-17 22:50:43', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1546, 163, 'Login', '2024-02-17 22:53:31', '2a02:4780:11::4f', 'User Shahed Bagwan logged-in successfully'),
(1547, 79, 'Login', '2024-02-17 22:54:34', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1548, 153, 'Login', '2024-02-17 22:56:07', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1549, 163, 'Login', '2024-02-17 22:57:42', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1550, 153, 'Login', '2024-02-17 22:59:30', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1551, 163, 'Login', '2024-02-17 23:00:00', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1552, 163, 'Login', '2024-02-17 23:03:45', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1553, 163, 'Login', '2024-02-17 23:14:31', '2a02:4780:11::4f', 'User Shahed Bagwan logged-in successfully'),
(1554, 163, 'Login', '2024-02-17 23:15:26', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1555, 82, 'Update profile', '2024-02-18 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1556, 116, 'Update profile', '2024-02-18 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1557, 157, 'Update profile', '2024-02-18 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1558, 79, 'Logoff', '2024-02-18 01:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1559, 153, 'Logoff', '2024-02-18 01:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1560, 154, 'Logoff', '2024-02-18 01:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1561, 153, 'Login', '2024-02-18 01:11:22', '206.169.137.201', 'User Alison Vickers logged-in successfully'),
(1562, 163, 'Login', '2024-02-18 01:14:18', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1563, 79, 'Login', '2024-02-18 03:40:29', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1564, 153, 'Login', '2024-02-18 03:47:08', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1565, 79, 'Login', '2024-02-18 03:52:07', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1566, 79, 'Login', '2024-02-18 03:53:23', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1567, 153, 'Login', '2024-02-18 03:55:20', '106.216.130.67', 'User Alison Vickers logged-in successfully'),
(1568, 153, 'Login', '2024-02-18 03:56:08', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1569, 163, 'Logoff', '2024-02-18 04:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1570, 79, 'Login', '2024-02-18 04:54:53', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1571, 160, 'Login', '2024-02-18 05:00:36', '2a02:4780:11::4f', 'User Confo Teacher 1 imporsonated by Super Admin successfully'),
(1572, 79, 'Login', '2024-02-18 05:06:58', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1573, 160, 'Login', '2024-02-18 05:07:35', '2a02:4780:11::4f', 'User Confo Teacher 1 logged-in successfully'),
(1574, 159, 'Login', '2024-02-18 05:12:26', '2a02:4780:11::4f', 'User Confo Manager imporsonated by Super Admin successfully'),
(1575, 159, 'Login', '2024-02-18 05:13:55', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(1576, 153, 'Logoff', '2024-02-18 06:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1577, 79, 'Logoff', '2024-02-18 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1578, 159, 'Logoff', '2024-02-18 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1579, 160, 'Logoff', '2024-02-18 08:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1580, 79, 'Login', '2024-02-18 08:07:24', '2401:4900:4c64:925c:1c49:aa93:4f20:7922', 'User Super Admin logged-in successfully'),
(1581, 160, 'Login', '2024-02-18 08:08:45', '106.216.130.67', 'User Confo Teacher 1 logged-in successfully'),
(1582, 79, 'Login', '2024-02-18 08:09:25', '106.216.130.67', 'User Super Admin logged-in successfully'),
(1583, 159, 'Login', '2024-02-18 08:09:42', '106.216.130.67', 'User Confo Manager imporsonated by Super Admin successfully'),
(1584, 160, 'Login', '2024-02-18 08:10:15', '106.216.130.67', 'User Confo Teacher 1 logged-in successfully'),
(1585, 160, 'Login', '2024-02-18 08:11:57', '2401:4900:4c64:925c:1c49:aa93:4f20:7922', 'User Confo Teacher 1 logged-in successfully'),
(1586, 159, 'Login', '2024-02-18 08:12:25', '106.216.130.67', 'User Confo Manager logged-in successfully'),
(1587, 160, 'Login', '2024-02-18 08:13:25', '106.216.130.67', 'User Confo Teacher 1 logged-in successfully'),
(1588, 160, 'Login', '2024-02-18 08:14:52', '2a02:4780:11::4f', 'User Confo Teacher 1 logged-in successfully'),
(1589, 159, 'Login', '2024-02-18 08:15:22', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(1590, 160, 'Login', '2024-02-18 08:15:54', '2a02:4780:11::4f', 'User Confo Teacher 1 logged-in successfully'),
(1591, 159, 'Login', '2024-02-18 08:16:47', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(1592, 79, 'Login', '2024-02-18 08:17:13', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1593, 153, 'Login', '2024-02-18 08:22:31', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1594, 159, 'Login', '2024-02-18 08:23:22', '106.216.130.67', 'User Confo Manager logged-in successfully'),
(1595, 160, 'Login', '2024-02-18 08:29:29', '2401:4900:4c64:925c:1c49:aa93:4f20:7922', 'User Confo Teacher 1 logged-in successfully'),
(1596, 159, 'Login', '2024-02-18 08:30:11', '2401:4900:4c64:925c:1c49:aa93:4f20:7922', 'User Confo Manager logged-in successfully'),
(1597, 160, 'Login', '2024-02-18 08:31:11', '106.216.130.67', 'User Confo Teacher 1 logged-in successfully'),
(1598, 160, 'Login', '2024-02-18 08:50:08', '49.37.226.66', 'User Confo Teacher 1 logged-in successfully'),
(1599, 159, 'Login', '2024-02-18 08:51:44', '49.37.226.66', 'User Confo Manager logged-in successfully'),
(1600, 159, 'Login', '2024-02-18 09:22:00', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(1601, 160, 'Login', '2024-02-18 09:22:42', '2a02:4780:11::4f', 'User Confo Teacher 1 logged-in successfully'),
(1602, 159, 'Login', '2024-02-18 09:23:13', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(1603, 160, 'Login', '2024-02-18 09:23:21', '49.37.226.66', 'User Confo Teacher 1 logged-in successfully'),
(1604, 160, 'Login', '2024-02-18 09:24:40', '49.37.226.66', 'User Confo Teacher 1 logged-in successfully'),
(1605, 160, 'Login', '2024-02-18 09:24:59', '2a02:4780:11::4f', 'User Confo Teacher 1 logged-in successfully'),
(1606, 160, 'Login', '2024-02-18 09:25:11', '2a02:4780:11::4f', 'User Confo Teacher 1 logged-in successfully'),
(1607, 160, 'Login', '2024-02-18 09:46:16', '49.37.226.66', 'User Confo Teacher 1 logged-in successfully'),
(1608, 79, 'Login', '2024-02-18 09:47:18', '49.37.226.66', 'User Super Admin logged-in successfully'),
(1609, 160, 'Login', '2024-02-18 09:49:13', '49.37.226.66', 'User Confo Teacher 1 logged-in successfully'),
(1610, 79, 'Login', '2024-02-18 09:51:41', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1611, 159, 'Login', '2024-02-18 09:51:44', '49.37.226.66', 'User Confo Manager logged-in successfully'),
(1612, 160, 'Login', '2024-02-18 09:53:59', '49.37.226.66', 'User Confo Teacher 1 logged-in successfully'),
(1613, 160, 'Login', '2024-02-18 09:55:29', '2a02:4780:11::4f', 'User Confo Teacher 1 logged-in successfully'),
(1614, 160, 'Login', '2024-02-18 09:56:12', '2a02:4780:11::4f', 'User Confo Teacher 1 logged-in successfully'),
(1615, 159, 'Login', '2024-02-18 09:56:43', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(1616, 159, 'Login', '2024-02-18 10:01:56', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(1617, 159, 'Login', '2024-02-18 10:45:34', '49.37.226.66', 'User Confo Manager logged-in successfully'),
(1618, 160, 'Login', '2024-02-18 10:46:37', '49.37.226.66', 'User Confo Teacher 1 logged-in successfully'),
(1619, 153, 'Logoff', '2024-02-18 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1620, 79, 'Login', '2024-02-18 11:09:25', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1621, 79, 'Login', '2024-02-18 11:25:15', '106.216.130.67', 'User Super Admin logged-in successfully'),
(1622, 159, 'Login', '2024-02-18 11:27:52', '2401:4900:4c64:925c:1c49:aa93:4f20:7922', 'User Confo Manager logged-in successfully'),
(1623, 160, 'Login', '2024-02-18 11:29:51', '106.216.130.67', 'User Confo Teacher 1 logged-in successfully'),
(1624, 159, 'Login', '2024-02-18 11:32:26', '117.208.16.80', 'User Confo Manager logged-in successfully'),
(1625, 160, 'Login', '2024-02-18 11:33:35', '117.208.16.80', 'User Confo Teacher 1 logged-in successfully'),
(1626, 159, 'Login', '2024-02-18 11:34:15', '117.208.16.80', 'User Confo Manager logged-in successfully'),
(1627, 160, 'Login', '2024-02-18 11:34:45', '117.208.16.80', 'User Confo Teacher 1 logged-in successfully'),
(1628, 79, 'Login', '2024-02-18 11:43:40', '117.208.16.80', 'User Super Admin logged-in successfully'),
(1629, 159, 'Login', '2024-02-18 13:57:29', '49.37.227.139', 'User Confo Manager logged-in successfully'),
(1630, 79, 'Logoff', '2024-02-18 14:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1631, 160, 'Logoff', '2024-02-18 14:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1632, 159, 'Logoff', '2024-02-18 16:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1633, 79, 'Login', '2024-02-18 17:10:45', '117.208.16.80', 'User Super Admin logged-in successfully'),
(1634, 159, 'Login', '2024-02-18 17:12:20', '117.208.16.80', 'User Confo Manager logged-in successfully'),
(1635, 160, 'Login', '2024-02-18 17:14:10', '117.208.16.80', 'User Confo Teacher 1 logged-in successfully'),
(1636, 160, 'Login', '2024-02-18 17:17:25', '117.208.16.80', 'User Confo Teacher 1 logged-in successfully'),
(1637, 159, 'Login', '2024-02-18 17:18:30', '117.208.16.80', 'User Confo Manager logged-in successfully'),
(1638, 160, 'Login', '2024-02-18 17:42:15', '117.208.16.80', 'User Confo Teacher 1 logged-in successfully'),
(1639, 79, 'Login', '2024-02-18 17:42:40', '117.208.16.80', 'User Super Admin logged-in successfully'),
(1640, 79, 'Logoff', '2024-02-18 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1641, 159, 'Logoff', '2024-02-18 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1642, 160, 'Logoff', '2024-02-18 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1643, 163, 'Login', '2024-02-19 21:44:38', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1644, 153, 'Login', '2024-02-19 21:45:47', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1645, 163, 'Login', '2024-02-19 21:46:55', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1646, 163, 'Login', '2024-02-19 21:53:01', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1647, 163, 'Login', '2024-02-19 22:00:03', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1648, 163, 'Login', '2024-02-19 22:13:46', '172.56.208.233', 'User Shahed Bagwan logged-in successfully'),
(1649, 163, 'Login', '2024-02-19 22:16:49', '172.56.208.233', 'User Shahed Bagwan logged-in successfully'),
(1650, 163, 'Login', '2024-02-19 22:17:23', '172.56.208.233', 'User Shahed Bagwan logged-in successfully'),
(1651, 163, 'Login', '2024-02-19 22:26:36', '172.56.208.233', 'User Shahed Bagwan logged-in successfully'),
(1652, 163, 'Login', '2024-02-19 22:31:03', '2607:fb91:106:4f25:8c38:37ae:c04a:605d', 'User Shahed Bagwan logged-in successfully'),
(1653, 163, 'Login', '2024-02-19 22:32:03', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1654, 163, 'Login', '2024-02-19 22:33:36', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1655, 163, 'Login', '2024-02-19 22:35:44', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1656, 163, 'Login', '2024-02-19 22:36:51', '172.56.209.45', 'User Shahed Bagwan logged-in successfully'),
(1657, 153, 'Logoff', '2024-02-20 00:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1658, 163, 'Logoff', '2024-02-20 01:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1659, 159, 'Login', '2024-02-20 02:56:28', '117.208.27.247', 'User Confo Manager logged-in successfully'),
(1660, 164, 'Login', '2024-02-20 02:58:01', '117.208.27.247', 'User confo teacher2 logged-in successfully'),
(1661, 164, 'Login', '2024-02-20 02:59:09', '117.208.27.247', 'User confo teacher2 logged-in successfully'),
(1662, 164, 'Login', '2024-02-20 03:01:30', '117.208.27.247', 'User confo teacher2 logged-in successfully'),
(1663, 159, 'Login', '2024-02-20 03:02:39', '117.208.27.247', 'User Confo Manager logged-in successfully'),
(1664, 164, 'Login', '2024-02-20 03:03:27', '117.208.27.247', 'User confo teacher2 logged-in successfully'),
(1665, 159, 'Login', '2024-02-20 03:06:04', '117.208.27.247', 'User Confo Manager logged-in successfully'),
(1666, 160, 'Login', '2024-02-20 03:07:42', '117.208.27.247', 'User Confo Teacher 1 logged-in successfully'),
(1667, 160, 'Login', '2024-02-20 03:08:50', '117.208.27.247', 'User Confo Teacher 1 logged-in successfully'),
(1668, 160, 'Login', '2024-02-20 03:12:31', '117.208.27.247', 'User Confo Teacher 1 logged-in successfully'),
(1669, 160, 'Login', '2024-02-20 03:14:14', '117.208.27.247', 'User Confo Teacher 1 logged-in successfully'),
(1670, 160, 'Login', '2024-02-20 03:24:30', '117.208.27.247', 'User Confo Teacher 1 logged-in successfully'),
(1671, 160, 'Login', '2024-02-20 04:04:37', '106.200.21.242', 'User Confo Teacher 1 logged-in successfully'),
(1672, 160, 'Login', '2024-02-20 04:14:22', '117.208.27.247', 'User Confo Teacher 1 logged-in successfully'),
(1673, 159, 'Login', '2024-02-20 04:14:46', '117.208.27.247', 'User Confo Manager logged-in successfully'),
(1674, 159, 'Login', '2024-02-20 04:16:18', '117.208.27.247', 'User Confo Manager logged-in successfully'),
(1675, 165, 'Login', '2024-02-20 04:16:40', '117.208.27.247', 'User confo 3 logged-in successfully'),
(1676, 164, 'Logoff', '2024-02-20 06:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1677, 159, 'Login', '2024-02-20 06:54:43', '110.225.158.51', 'User Confo Manager logged-in successfully'),
(1678, 159, 'Login', '2024-02-20 06:59:10', '110.225.158.51', 'User Confo Manager logged-in successfully'),
(1679, 160, 'Logoff', '2024-02-20 07:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1680, 165, 'Logoff', '2024-02-20 07:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1681, 166, 'Login', '2024-02-20 07:50:58', '110.225.158.51', 'User Teacher 01 logged-in successfully'),
(1682, 159, 'Login', '2024-02-20 08:00:12', '157.44.201.84', 'User Confo Manager logged-in successfully'),
(1683, 163, 'Login', '2024-02-20 08:02:21', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1684, 163, 'Login', '2024-02-20 08:03:54', '206.169.137.201', 'User Shahed Bagwan logged-in successfully'),
(1685, 167, 'Login', '2024-02-20 08:05:06', '157.44.205.175', 'User teacher 2 logged-in successfully'),
(1686, 159, 'Login', '2024-02-20 08:05:30', '157.44.205.175', 'User Confo Manager logged-in successfully'),
(1687, 167, 'Login', '2024-02-20 08:06:05', '2409:4073:30e:706c::1069:e0a5', 'User teacher 2 logged-in successfully'),
(1688, 160, 'Login', '2024-02-20 08:35:49', '223.185.203.24', 'User Confo Teacher 1 logged-in successfully'),
(1689, 159, 'Login', '2024-02-20 08:36:14', '223.185.203.24', 'User Confo Manager logged-in successfully'),
(1690, 160, 'Login', '2024-02-20 08:37:29', '2401:4900:2628:5d62:4d6e:d904:8f1a:398b', 'User Confo Teacher 1 logged-in successfully'),
(1691, 159, 'Login', '2024-02-20 08:39:00', '2401:4900:2628:5d62:c50b:af06:1cc9:abfc', 'User Confo Manager logged-in successfully'),
(1692, 160, 'Login', '2024-02-20 08:39:36', '223.185.203.24', 'User Confo Teacher 1 logged-in successfully'),
(1693, 160, 'Login', '2024-02-20 08:40:38', '223.185.203.24', 'User Confo Teacher 1 logged-in successfully'),
(1694, 163, 'Login', '2024-02-20 09:13:37', '49.37.227.139', 'User Shahed Bagwan logged-in successfully'),
(1695, 163, 'Login', '2024-02-20 09:15:59', '49.37.227.139', 'User Shahed Bagwan logged-in successfully'),
(1696, 166, 'Logoff', '2024-02-20 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1697, 159, 'Logoff', '2024-02-20 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1698, 160, 'Logoff', '2024-02-20 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1699, 167, 'Logoff', '2024-02-20 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1700, 163, 'Login', '2024-02-20 11:11:49', '2405:201:f002:8125:50fd:fe70:67c7:3e3a', 'User Shahed Bagwan logged-in successfully'),
(1701, 163, 'Logoff', '2024-02-20 14:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1702, 163, 'Login', '2024-02-20 17:27:54', '2a02:4780:11::4f', 'User Shahed Bagwan logged-in successfully'),
(1703, 163, 'Login', '2024-02-20 17:28:11', '2a02:4780:11::4f', 'User Shahed Bagwan logged-in successfully'),
(1704, 163, 'Login', '2024-02-20 17:28:38', '2a02:4780:11::4f', 'User Shahed Bagwan logged-in successfully'),
(1705, 163, 'Login', '2024-02-20 17:41:40', '2a02:4780:11::4f', 'User Shahed Bagwan logged-in successfully'),
(1706, 163, 'Login', '2024-02-20 17:46:16', '2a02:4780:11::4f', 'User Shahed Bagwan logged-in successfully'),
(1707, 163, 'Logoff', '2024-02-20 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1708, 79, 'Update profile', '2024-02-21 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1709, 154, 'Update profile', '2024-02-21 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1710, 153, 'Update profile', '2024-02-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1711, 159, 'Update profile', '2024-02-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1712, 160, 'Update profile', '2024-02-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1713, 163, 'Update profile', '2024-02-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1714, 164, 'Update profile', '2024-02-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1715, 165, 'Update profile', '2024-02-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1716, 166, 'Update profile', '2024-02-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1717, 167, 'Update profile', '2024-02-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1718, 163, 'Login', '2024-02-24 09:25:31', '59.153.113.138', 'User Shahed Bagwan logged-in successfully'),
(1719, 56, 'Login', '2024-02-24 10:08:14', '58.178.56.87', 'User Habeeb Rahman logged-in successfully'),
(1720, 79, 'Login', '2024-02-24 11:57:11', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1721, 163, 'Logoff', '2024-02-24 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1722, 56, 'Logoff', '2024-02-24 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1723, 79, 'Logoff', '2024-02-24 14:00:01', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1724, 79, 'Login', '2024-02-26 09:03:20', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1725, 79, 'Logoff', '2024-02-26 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1726, 163, 'Login', '2024-02-26 19:13:52', '2a02:4780:11::4f', 'User Shahed Bagwan logged-in successfully'),
(1727, 79, 'Login', '2024-02-26 19:15:58', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1728, 153, 'Login', '2024-02-26 19:16:50', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1729, 163, 'Login', '2024-02-26 19:20:10', '73.189.164.172', 'User Shahed Bagwan logged-in successfully'),
(1730, 163, 'Login', '2024-02-26 19:23:40', '2a02:4780:11::4f', 'User Shahed Bagwan logged-in successfully'),
(1731, 79, 'Logoff', '2024-02-26 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1732, 153, 'Logoff', '2024-02-26 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1733, 163, 'Logoff', '2024-02-26 22:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1734, 56, 'Update profile', '2024-02-27 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1735, 79, 'Update profile', '2024-02-29 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1736, 153, 'Update profile', '2024-02-29 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1737, 163, 'Update profile', '2024-02-29 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1738, 79, 'Login', '2024-03-05 06:35:18', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1739, 79, 'Login', '2024-03-05 06:35:33', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1740, 79, 'Login', '2024-03-05 06:47:19', '103.141.55.234', 'User Super Admin logged-in successfully'),
(1741, 83, 'Login', '2024-03-05 06:47:53', '103.141.55.234', 'User Reese Grays logged-in successfully'),
(1742, 79, 'Login', '2024-03-05 06:48:03', '103.141.55.234', 'User Super Admin logged-in successfully'),
(1743, 148, 'Login', '2024-03-05 06:48:56', '103.141.55.234', 'User Missouri Teacher imporsonated by Super Admin successfully'),
(1744, 79, 'Login', '2024-03-05 06:49:28', '103.141.55.234', 'User Super Admin logged-in successfully'),
(1745, 148, 'Login', '2024-03-05 06:49:58', '103.141.55.234', 'User Missouri Teacher imporsonated by Super Admin successfully'),
(1746, 79, 'Login', '2024-03-05 06:59:20', '202.88.246.56', 'User Super Admin logged-in successfully'),
(1747, 148, 'Login', '2024-03-05 06:59:34', '202.88.246.56', 'User Missouri Teacher imporsonated by Super Admin successfully'),
(1748, 79, 'Login', '2024-03-05 07:09:36', '103.141.55.234', 'User Super Admin logged-in successfully'),
(1749, 148, 'Login', '2024-03-05 07:09:48', '103.141.55.234', 'User Missouri Teacher imporsonated by Super Admin successfully'),
(1750, 79, 'Login', '2024-03-05 08:08:29', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1751, 83, 'Logoff', '2024-03-05 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1752, 148, 'Logoff', '2024-03-05 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1753, 159, 'Login', '2024-03-05 10:21:19', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(1754, 79, 'Logoff', '2024-03-05 11:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1755, 160, 'Login', '2024-03-05 12:55:52', '2a02:4780:11::4f', 'User Confo Teacher 1 logged-in successfully'),
(1756, 159, 'Login', '2024-03-05 12:56:09', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(1757, 159, 'Logoff', '2024-03-05 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1758, 160, 'Logoff', '2024-03-05 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1759, 163, 'Login', '2024-03-06 00:48:56', '2a02:4780:11::4f', 'User Shahed Bagwan logged-in successfully'),
(1760, 163, 'Logoff', '2024-03-06 03:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1761, 159, 'Login', '2024-03-06 05:05:59', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(1762, 159, 'Logoff', '2024-03-06 08:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1763, 79, 'Login', '2024-03-06 09:19:41', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1764, 79, 'Login', '2024-03-06 09:24:45', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1765, 79, 'Login', '2024-03-06 09:25:51', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1766, 168, 'Login', '2024-03-06 10:15:41', '2a02:4780:11::4f', 'User Mushthaqu Tc logged-in successfully'),
(1767, 79, 'Logoff', '2024-03-06 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1768, 79, 'Login', '2024-03-06 12:10:02', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1769, 79, 'Logoff', '2024-03-06 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1770, 79, 'Login', '2024-03-07 14:54:33', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1771, 58, 'Login', '2024-03-07 14:55:03', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1772, 79, 'Login', '2024-03-07 15:09:16', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1773, 79, 'Login', '2024-03-07 15:21:23', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1774, 58, 'Logoff', '2024-03-07 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1775, 79, 'Logoff', '2024-03-07 18:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1776, 83, 'Update profile', '2024-03-08 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1777, 148, 'Update profile', '2024-03-08 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1778, 160, 'Update profile', '2024-03-08 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1779, 79, 'Login', '2024-03-08 04:36:25', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1780, 79, 'Logoff', '2024-03-08 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry');
INSERT INTO `tbl_user_login_audit` (`userLoginAuditId`, `userProfileId`, `action`, `actionDateTime`, `deviceId`, `comments`) VALUES
(1781, 159, 'Update profile', '2024-03-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1782, 163, 'Update profile', '2024-03-09 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1783, 79, 'Login', '2024-03-09 03:49:38', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1784, 79, 'Logoff', '2024-03-09 06:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1785, 58, 'Update profile', '2024-03-10 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1786, 79, 'Login', '2024-03-11 04:17:44', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1787, 79, 'Logoff', '2024-03-11 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1788, 58, 'Login', '2024-03-11 09:59:03', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1789, 58, 'Logoff', '2024-03-11 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1790, 79, 'Login', '2024-03-13 11:07:52', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1791, 93, 'Login', '2024-03-13 11:08:19', '2a02:4780:11::4f', 'User Cameron Hinton logged-in successfully'),
(1792, 79, 'Login', '2024-03-13 11:08:59', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1793, 153, 'Login', '2024-03-13 11:09:33', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1794, 79, 'Logoff', '2024-03-13 14:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1795, 93, 'Logoff', '2024-03-13 14:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1796, 153, 'Logoff', '2024-03-13 14:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1797, 58, 'Update profile', '2024-03-14 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1798, 79, 'Update profile', '2024-03-16 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1799, 93, 'Update profile', '2024-03-16 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1800, 153, 'Update profile', '2024-03-16 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1801, 79, 'Login', '2024-03-27 15:28:08', '106.194.40.24', 'User Super Admin logged-in successfully'),
(1802, 82, 'Logoff', '2024-03-27 16:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1803, 79, 'Login', '2024-03-27 17:24:02', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1804, 79, 'Login', '2024-03-27 17:32:35', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1805, 79, 'Login', '2024-03-27 17:33:26', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1806, 153, 'Login', '2024-03-27 17:33:46', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(1807, 79, 'Logoff', '2024-03-27 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1808, 153, 'Logoff', '2024-03-27 20:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1809, 79, 'Update profile', '2024-03-30 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1810, 82, 'Update profile', '2024-03-30 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1811, 153, 'Update profile', '2024-03-30 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1812, 56, 'Login', '2024-04-19 13:10:49', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1813, 57, 'Login', '2024-04-19 13:12:01', '2a02:4780:11::4f', 'User Alen Cooper imporsonated by Habeeb Rahman successfully'),
(1814, 56, 'Login', '2024-04-19 13:17:57', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1815, 56, 'Login', '2024-04-19 13:28:31', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1816, 56, 'Login', '2024-04-19 13:36:57', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1817, 56, 'Logoff', '2024-04-19 16:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1818, 57, 'Logoff', '2024-04-19 16:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1819, 79, 'Login', '2024-04-20 09:24:59', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1820, 79, 'Logoff', '2024-04-20 12:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1821, 56, 'Update profile', '2024-04-22 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1822, 57, 'Update profile', '2024-04-22 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1823, 79, 'Update profile', '2024-04-23 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1824, 56, 'Login', '2024-04-23 07:07:14', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1825, 56, 'Login', '2024-04-23 07:16:48', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1826, 56, 'Login', '2024-04-23 07:23:46', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1827, 57, 'Login', '2024-04-23 07:36:03', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(1828, 56, 'Login', '2024-04-23 07:36:49', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1829, 57, 'Login', '2024-04-23 07:49:17', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(1830, 56, 'Login', '2024-04-23 09:03:23', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1831, 76, 'Login', '2024-04-23 09:03:49', '2a02:4780:11::4f', 'User Nero Guerra logged-in successfully'),
(1832, 56, 'Login', '2024-04-23 09:10:08', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1833, 76, 'Login', '2024-04-23 09:11:59', '2a02:4780:11::4f', 'User Nero Guerra logged-in successfully'),
(1834, 56, 'Login', '2024-04-23 09:13:45', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1835, 57, 'Login', '2024-04-23 09:14:24', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(1836, 56, 'Login', '2024-04-23 09:14:51', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1837, 58, 'Login', '2024-04-23 09:15:41', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1838, 71, 'Login', '2024-04-23 09:16:42', '2a02:4780:11::4f', 'User Theodora Reynolds d logged-in successfully'),
(1839, 71, 'Login', '2024-04-23 09:17:32', '2a02:4780:11::4f', 'User Theodora Reynolds d logged-in successfully'),
(1840, 56, 'Login', '2024-04-23 09:43:20', '106.222.237.76', 'User Habeeb Rahman logged-in successfully'),
(1841, 56, 'Login', '2024-04-23 09:43:35', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1842, 56, 'Logoff', '2024-04-23 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1843, 57, 'Logoff', '2024-04-23 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1844, 58, 'Logoff', '2024-04-23 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1845, 71, 'Logoff', '2024-04-23 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1846, 76, 'Logoff', '2024-04-23 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1847, 56, 'Login', '2024-04-23 13:11:53', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1848, 58, 'Login', '2024-04-23 13:41:27', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1849, 58, 'Login', '2024-04-23 13:43:07', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1850, 58, 'Login', '2024-04-23 13:43:12', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1851, 58, 'Login', '2024-04-23 13:46:37', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1852, 56, 'Login', '2024-04-23 13:47:06', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1853, 58, 'Login', '2024-04-23 13:47:36', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1854, 56, 'Login', '2024-04-23 13:48:00', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1855, 58, 'Login', '2024-04-23 14:00:39', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1856, 56, 'Login', '2024-04-23 14:09:04', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1857, 76, 'Login', '2024-04-23 14:09:19', '2a02:4780:11::4f', 'User Nero Guerra imporsonated by Habeeb Rahman successfully'),
(1858, 56, 'Login', '2024-04-23 14:09:39', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1859, 168, 'Logoff', '2024-04-23 15:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1860, 56, 'Logoff', '2024-04-23 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1861, 58, 'Logoff', '2024-04-23 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1862, 76, 'Logoff', '2024-04-23 17:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1863, 56, 'Login', '2024-04-24 06:44:19', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1864, 56, 'Login', '2024-04-24 07:45:59', '157.46.130.226', 'User Habeeb Rahman logged-in successfully'),
(1865, 57, 'Login', '2024-04-24 07:47:26', '157.46.130.226', 'User Alen Cooper logged-in successfully'),
(1866, 58, 'Login', '2024-04-24 07:48:30', '157.46.130.226', 'User John Doe logged-in successfully'),
(1867, 57, 'Login', '2024-04-24 07:52:24', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(1868, 76, 'Login', '2024-04-24 07:59:33', '2a02:4780:11::4f', 'User Nero Guerra logged-in successfully'),
(1869, 56, 'Login', '2024-04-24 07:59:56', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1870, 71, 'Login', '2024-04-24 08:00:42', '2a02:4780:11::4f', 'User Theodora Reynolds d logged-in successfully'),
(1871, 167, 'Login', '2024-04-24 08:01:13', '157.46.130.226', 'User teacher 2 logged-in successfully'),
(1872, 71, 'Login', '2024-04-24 08:01:53', '157.46.130.226', 'User Theodora Reynolds d logged-in successfully'),
(1873, 56, 'Login', '2024-04-24 08:04:08', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1874, 56, 'Login', '2024-04-24 09:32:32', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1875, 58, 'Login', '2024-04-24 09:45:19', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1876, 58, 'Login', '2024-04-24 09:51:12', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1877, 58, 'Login', '2024-04-24 09:52:47', '157.46.135.27', 'User John Doe logged-in successfully'),
(1878, 57, 'Logoff', '2024-04-24 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1879, 76, 'Logoff', '2024-04-24 10:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1880, 71, 'Login', '2024-04-24 10:02:05', '2a02:4780:11::4f', 'User Theodora Reynolds d logged-in successfully'),
(1881, 58, 'Login', '2024-04-24 10:03:02', '2a02:4780:11::4f', 'User John Doe logged-in successfully'),
(1882, 167, 'Logoff', '2024-04-24 11:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1883, 56, 'Logoff', '2024-04-24 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1884, 58, 'Logoff', '2024-04-24 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1885, 71, 'Logoff', '2024-04-24 13:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1886, 168, 'Update profile', '2024-04-26 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1887, 56, 'Update profile', '2024-04-27 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1888, 57, 'Update profile', '2024-04-27 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1889, 58, 'Update profile', '2024-04-27 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1890, 71, 'Update profile', '2024-04-27 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1891, 76, 'Update profile', '2024-04-27 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1892, 167, 'Update profile', '2024-04-27 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1893, 56, 'Login', '2024-04-27 11:01:34', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1894, 56, 'Login', '2024-04-27 11:02:06', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1895, 58, 'Login', '2024-04-27 11:02:28', '2a02:4780:11::4f', 'User John Doe imporsonated by Habeeb Rahman successfully'),
(1896, 56, 'Logoff', '2024-04-27 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1897, 58, 'Logoff', '2024-04-27 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1898, 56, 'Update profile', '2024-04-30 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1899, 58, 'Update profile', '2024-04-30 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1900, 79, 'Login', '2024-04-30 04:47:12', '103.141.55.234', 'User Super Admin logged-in successfully'),
(1901, 79, 'Logoff', '2024-04-30 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1902, 79, 'Update profile', '2024-05-03 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1903, 79, 'Login', '2024-05-03 04:36:25', '103.141.55.234', 'User Super Admin logged-in successfully'),
(1904, 79, 'Logoff', '2024-05-03 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1905, 79, 'Login', '2024-05-03 13:16:48', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1906, 79, 'Login', '2024-05-03 13:19:10', '103.146.175.172', 'User Super Admin logged-in successfully'),
(1907, 79, 'Logoff', '2024-05-03 16:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1908, 79, 'Login', '2024-05-04 16:06:17', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1909, 79, 'Logoff', '2024-05-04 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1910, 79, 'Update profile', '2024-05-07 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1911, 79, 'Login', '2024-05-08 16:40:55', '49.37.232.224', 'User Super Admin logged-in successfully'),
(1912, 82, 'Login', '2024-05-08 16:47:34', '49.37.232.224', 'User Reese Haynes logged-in successfully'),
(1913, 79, 'Login', '2024-05-08 16:47:44', '49.37.232.224', 'User Super Admin logged-in successfully'),
(1914, 159, 'Login', '2024-05-08 16:48:23', '2405:201:f002:80b2:bcac:6b61:eb0e:b2f1', 'User Confo Manager imporsonated by Super Admin successfully'),
(1915, 79, 'Login', '2024-05-08 17:04:54', '49.37.232.224', 'User Super Admin logged-in successfully'),
(1916, 82, 'Logoff', '2024-05-08 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1917, 159, 'Logoff', '2024-05-08 19:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1918, 79, 'Logoff', '2024-05-08 20:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1919, 56, 'Login', '2024-05-09 10:13:20', '103.151.189.165', 'User Habeeb Rahman logged-in successfully'),
(1920, 56, 'Login', '2024-05-09 11:28:05', '103.151.189.165', 'User Habeeb Rahman logged-in successfully'),
(1921, 56, 'Login', '2024-05-09 11:28:28', '103.151.189.165', 'User Habeeb Rahman logged-in successfully'),
(1922, 56, 'Login', '2024-05-09 11:29:01', '103.151.189.165', 'User Habeeb Rahman logged-in successfully'),
(1923, 56, 'Login', '2024-05-09 12:15:22', '103.151.189.165', 'User Habeeb Rahman logged-in successfully'),
(1924, 56, 'Logoff', '2024-05-09 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1925, 79, 'Login', '2024-05-09 15:45:41', '49.37.232.224', 'User Super Admin logged-in successfully'),
(1926, 79, 'Logoff', '2024-05-09 18:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1927, 56, 'Login', '2024-05-10 06:42:07', '157.46.133.221', 'User Habeeb Rahman logged-in successfully'),
(1928, 71, 'Login', '2024-05-10 08:57:56', '157.46.132.19', 'User Theodora Reynolds d logged-in successfully'),
(1929, 56, 'Login', '2024-05-10 08:58:41', '157.46.132.19', 'User Habeeb Rahman logged-in successfully'),
(1930, 56, 'Login', '2024-05-10 09:02:31', '157.46.132.19', 'User Habeeb Rahman logged-in successfully'),
(1931, 58, 'Login', '2024-05-10 09:13:28', '157.46.132.19', 'User John Doe logged-in successfully'),
(1932, 58, 'Login', '2024-05-10 09:14:13', '157.46.132.19', 'User John Doen logged-in successfully'),
(1933, 56, 'Login', '2024-05-10 09:14:41', '157.46.132.19', 'User Habeeb Rahman logged-in successfully'),
(1934, 58, 'Login', '2024-05-10 10:14:59', '2409:4073:2116:9123::df9:70b1', 'User John Doen logged-in successfully'),
(1935, 56, 'Login', '2024-05-10 10:17:05', '157.46.132.19', 'User Habeeb Rahman logged-in successfully'),
(1936, 71, 'Login', '2024-05-10 10:19:27', '157.46.132.19', 'User Theodora Reynolds d logged-in successfully'),
(1937, 58, 'Login', '2024-05-10 10:21:36', '157.46.132.19', 'User John Doen logged-in successfully'),
(1938, 56, 'Login', '2024-05-10 10:24:09', '157.46.132.19', 'User Habeeb Rahman logged-in successfully'),
(1939, 56, 'Login', '2024-05-10 10:41:42', '106.222.239.213', 'User Habeeb Rahman logged-in successfully'),
(1940, 56, 'Login', '2024-05-10 10:44:47', '106.222.239.213', 'User Habeeb Rahman logged-in successfully'),
(1941, 56, 'Login', '2024-05-10 12:22:41', '106.222.239.213', 'User Habeeb Rahman logged-in successfully'),
(1942, 56, 'Login', '2024-05-10 12:23:39', '106.222.239.213', 'User Habeeb Rahman logged-in successfully'),
(1943, 58, 'Logoff', '2024-05-10 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1944, 71, 'Logoff', '2024-05-10 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1945, 56, 'Logoff', '2024-05-10 15:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1946, 56, 'Login', '2024-05-10 17:20:12', '2401:4900:1cdf:6621:e084:1609:b2da:c291', 'User Habeeb Rahman logged-in successfully'),
(1947, 71, 'Login', '2024-05-10 17:30:06', '2401:4900:1cdf:6621:e084:1609:b2da:c291', 'User Theodora Reynolds d imporsonated by Habeeb Rahman successfully'),
(1948, 56, 'Login', '2024-05-10 17:31:18', '2401:4900:1cdf:6621:e084:1609:b2da:c291', 'User Habeeb Rahman logged-in successfully'),
(1949, 56, 'Logoff', '2024-05-10 20:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1950, 71, 'Logoff', '2024-05-10 20:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1951, 82, 'Update profile', '2024-05-11 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1952, 159, 'Update profile', '2024-05-11 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1953, 79, 'Update profile', '2024-05-12 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1954, 79, 'Login', '2024-05-12 06:59:01', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1955, 79, 'Login', '2024-05-12 08:15:59', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1956, 79, 'Login', '2024-05-12 08:23:28', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1957, 79, 'Logoff', '2024-05-12 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1958, 79, 'Login', '2024-05-12 11:16:30', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1959, 79, 'Login', '2024-05-12 11:36:38', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1960, 79, 'Login', '2024-05-12 12:14:18', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1961, 79, 'Logoff', '2024-05-12 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1962, 56, 'Update profile', '2024-05-13 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1963, 58, 'Update profile', '2024-05-13 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1964, 71, 'Update profile', '2024-05-13 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(1965, 79, 'Login', '2024-05-13 05:28:08', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1966, 79, 'Login', '2024-05-13 05:59:13', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1967, 58, 'Login', '2024-05-13 06:02:58', '2a02:4780:11::4f', 'User John Doen logged-in successfully'),
(1968, 57, 'Login', '2024-05-13 06:03:23', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(1969, 56, 'Login', '2024-05-13 06:03:50', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1970, 57, 'Login', '2024-05-13 06:06:48', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(1971, 76, 'Login', '2024-05-13 06:28:33', '2a02:4780:11::4f', 'User Nero Guerra logged-in successfully'),
(1972, 71, 'Login', '2024-05-13 06:28:45', '2a02:4780:11::4f', 'User Theodora Reynolds d logged-in successfully'),
(1973, 79, 'Login', '2024-05-13 06:31:23', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1974, 58, 'Login', '2024-05-13 07:16:39', '2a02:4780:11::4f', 'User John Doen logged-in successfully'),
(1975, 71, 'Login', '2024-05-13 07:20:11', '2a02:4780:11::4f', 'User Theodora Reynolds d logged-in successfully'),
(1976, 71, 'Login', '2024-05-13 07:20:32', '2a02:4780:11::4f', 'User Theodora Reynolds d logged-in successfully'),
(1977, 79, 'Login', '2024-05-13 07:21:36', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1978, 79, 'Login', '2024-05-13 07:22:03', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1979, 124, 'Login', '2024-05-13 07:23:10', '2a02:4780:11::4f', 'User Baby Bergstrom imporsonated by Super Admin successfully'),
(1980, 56, 'Logoff', '2024-05-13 09:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1981, 57, 'Logoff', '2024-05-13 09:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1982, 76, 'Logoff', '2024-05-13 09:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1983, 58, 'Logoff', '2024-05-13 10:00:11', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1984, 71, 'Logoff', '2024-05-13 10:00:11', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1985, 79, 'Logoff', '2024-05-13 10:00:11', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1986, 124, 'Logoff', '2024-05-13 10:00:11', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1987, 56, 'Login', '2024-05-13 11:10:49', '2a02:4780:11::4f', 'User Habeeb Rahman logged-in successfully'),
(1988, 57, 'Login', '2024-05-13 11:15:05', '2a02:4780:11::4f', 'User Alen Cooper logged-in successfully'),
(1989, 71, 'Login', '2024-05-13 11:16:20', '2a02:4780:11::4f', 'User Theodora Reynolds d logged-in successfully'),
(1990, 79, 'Login', '2024-05-13 11:17:00', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1991, 56, 'Logoff', '2024-05-13 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1992, 57, 'Logoff', '2024-05-13 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1993, 71, 'Logoff', '2024-05-13 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1994, 79, 'Logoff', '2024-05-13 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1995, 79, 'Login', '2024-05-13 14:23:50', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1996, 79, 'Logoff', '2024-05-13 17:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(1997, 79, 'Login', '2024-05-14 07:52:27', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1998, 79, 'Login', '2024-05-14 08:48:29', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(1999, 174, 'Login', '2024-05-14 10:52:48', '2a02:4780:11::4f', 'User mushthaq g logged-in successfully'),
(2000, 174, 'Login', '2024-05-14 10:53:10', '2a02:4780:11::4f', 'User mushthaq g logged-in successfully'),
(2001, 79, 'Login', '2024-05-14 10:57:02', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2002, 174, 'Login', '2024-05-14 10:57:13', '2a02:4780:11::4f', 'User mushthaq g logged-in successfully'),
(2003, 79, 'Login', '2024-05-14 10:59:29', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2004, 174, 'Login', '2024-05-14 11:00:59', '2a02:4780:11::4f', 'User mushthaq tc logged-in successfully'),
(2005, 159, 'Login', '2024-05-14 12:36:22', '2a02:4780:11::4f', 'User Confo Manager logged-in successfully'),
(2006, 79, 'Logoff', '2024-05-14 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2007, 79, 'Login', '2024-05-14 14:15:42', '106.222.236.252', 'User Super Admin logged-in successfully'),
(2008, 79, 'Login', '2024-05-14 14:16:58', '2401:4900:1cdc:2470:e084:1609:b2da:c291', 'User Super Admin logged-in successfully'),
(2009, 174, 'Login', '2024-05-14 14:19:12', '106.222.236.252', 'User Sreehari TP imporsonated by Super Admin successfully'),
(2010, 174, 'Login', '2024-05-14 14:20:20', '2401:4900:1cdc:2470:e084:1609:b2da:c291', 'User Sreehari TP logged-in successfully'),
(2011, 79, 'Login', '2024-05-14 14:24:52', '2401:4900:1cdc:2470:e084:1609:b2da:c291', 'User Super Admin logged-in successfully'),
(2012, 174, 'Login', '2024-05-14 14:40:22', '106.222.236.252', 'User Sreehari TP logged-in successfully'),
(2013, 175, 'Login', '2024-05-14 14:49:59', '2401:4900:1cdc:2470:e084:1609:b2da:c291', 'User deepak nair logged-in successfully'),
(2014, 79, 'Login', '2024-05-14 14:50:44', '106.222.236.252', 'User Super Admin logged-in successfully'),
(2015, 159, 'Logoff', '2024-05-14 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2016, 57, 'Login', '2024-05-14 15:01:48', '106.222.236.252', 'User Alen Cooper imporsonated by Super Admin successfully'),
(2017, 56, 'Login', '2024-05-14 15:16:51', '106.222.236.252', 'User Habeeb Rahman logged-in successfully'),
(2018, 79, 'Logoff', '2024-05-14 17:00:06', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2019, 174, 'Logoff', '2024-05-14 17:00:06', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2020, 175, 'Logoff', '2024-05-14 17:00:06', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2021, 56, 'Logoff', '2024-05-14 18:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2022, 57, 'Logoff', '2024-05-14 18:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2023, 79, 'Login', '2024-05-15 04:45:00', '103.176.185.9', 'User Super Admin logged-in successfully'),
(2024, 79, 'Login', '2024-05-15 05:12:52', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2025, 160, 'Login', '2024-05-15 06:18:44', '103.176.185.9', 'User Confo Teacher 1 logged-in successfully'),
(2026, 79, 'Login', '2024-05-15 06:29:04', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2027, 79, 'Login', '2024-05-15 07:49:42', '103.154.36.154', 'User Super Admin logged-in successfully'),
(2028, 160, 'Login', '2024-05-15 07:50:57', '103.154.36.154', 'User Confo Teacher 1 logged-in successfully'),
(2029, 79, 'Login', '2024-05-15 08:33:02', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2030, 160, 'Logoff', '2024-05-15 10:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2031, 79, 'Logoff', '2024-05-15 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2032, 58, 'Update profile', '2024-05-16 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2033, 71, 'Update profile', '2024-05-16 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2034, 76, 'Update profile', '2024-05-16 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2035, 124, 'Update profile', '2024-05-16 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2036, 79, 'Login', '2024-05-16 05:09:36', '103.179.196.33', 'User Super Admin logged-in successfully'),
(2037, 160, 'Login', '2024-05-16 05:20:21', '103.179.196.33', 'User Confo Teacher 1 logged-in successfully'),
(2038, 79, 'Login', '2024-05-16 06:31:11', '103.179.196.33', 'User Super Admin logged-in successfully'),
(2039, 160, 'Login', '2024-05-16 06:36:11', '103.179.196.33', 'User Confo Teacher 1 logged-in successfully'),
(2040, 79, 'Login', '2024-05-16 06:38:24', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2041, 79, 'Login', '2024-05-16 06:38:24', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2042, 79, 'Login', '2024-05-16 06:45:35', '103.179.196.33', 'User Super Admin logged-in successfully'),
(2043, 160, 'Login', '2024-05-16 06:46:37', '103.179.196.33', 'User Confo Teacher 1 logged-in successfully'),
(2044, 79, 'Login', '2024-05-16 07:50:58', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2045, 79, 'Login', '2024-05-16 07:59:27', '103.179.196.33', 'User Super Admin logged-in successfully'),
(2046, 160, 'Login', '2024-05-16 08:00:18', '103.179.196.33', 'User Confo Teacher 1 logged-in successfully'),
(2047, 79, 'Login', '2024-05-16 08:03:01', '103.179.196.33', 'User Super Admin logged-in successfully'),
(2048, 160, 'Login', '2024-05-16 08:03:58', '103.179.196.33', 'User Confo Teacher 1 logged-in successfully'),
(2049, 79, 'Login', '2024-05-16 08:06:46', '103.179.196.33', 'User Super Admin logged-in successfully'),
(2050, 160, 'Login', '2024-05-16 08:09:38', '103.179.196.33', 'User Confo Teacher 1 logged-in successfully'),
(2051, 79, 'Logoff', '2024-05-16 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2052, 160, 'Logoff', '2024-05-16 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2053, 79, 'Login', '2024-05-16 11:16:06', '103.179.196.33', 'User Super Admin logged-in successfully'),
(2054, 56, 'Login', '2024-05-16 12:12:44', '2401:4900:687d:fd63:c596:179:be87:c6b7', 'User Habeeb Rahman logged-in successfully'),
(2055, 79, 'Logoff', '2024-05-16 14:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2056, 56, 'Logoff', '2024-05-16 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2057, 57, 'Update profile', '2024-05-17 00:00:04', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2058, 159, 'Update profile', '2024-05-17 00:00:04', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2059, 174, 'Update profile', '2024-05-17 00:00:04', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2060, 175, 'Update profile', '2024-05-17 00:00:04', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2061, 79, 'Login', '2024-05-17 11:37:01', '103.153.105.132', 'User Super Admin logged-in successfully'),
(2062, 79, 'Login', '2024-05-17 12:39:15', '103.153.105.132', 'User Super Admin logged-in successfully'),
(2063, 79, 'Login', '2024-05-17 12:39:51', '103.153.105.132', 'User Super Admin logged-in successfully'),
(2064, 79, 'Login', '2024-05-17 12:57:09', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2065, 79, 'Login', '2024-05-17 12:58:10', '103.153.105.132', 'User Super Admin logged-in successfully'),
(2066, 79, 'Login', '2024-05-17 13:02:47', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2067, 79, 'Login', '2024-05-17 13:03:25', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2068, 79, 'Logoff', '2024-05-17 16:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2069, 79, 'Login', '2024-05-18 04:39:39', '103.153.104.207', 'User Super Admin logged-in successfully'),
(2070, 79, 'Login', '2024-05-18 05:35:59', '103.153.104.207', 'User Super Admin logged-in successfully'),
(2071, 79, 'Login', '2024-05-18 05:52:09', '103.153.104.207', 'User Super Admin logged-in successfully'),
(2072, 79, 'Login', '2024-05-18 06:55:35', '103.153.104.207', 'User Super Admin logged-in successfully'),
(2073, 79, 'Login', '2024-05-18 07:45:32', '103.153.104.207', 'User Super Admin logged-in successfully'),
(2074, 79, 'Login', '2024-05-18 07:47:05', '103.153.104.207', 'User Super Admin logged-in successfully'),
(2075, 79, 'Logoff', '2024-05-18 10:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2076, 56, 'Update profile', '2024-05-19 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2077, 160, 'Update profile', '2024-05-19 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2078, 56, 'Login', '2024-05-19 10:15:33', '58.178.56.87', 'User Habeeb Rahman logged-in successfully'),
(2079, 56, 'Logoff', '2024-05-19 13:00:05', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2080, 79, 'Update profile', '2024-05-21 00:00:04', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2081, 56, 'Update profile', '2024-05-22 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2082, 163, 'Login', '2024-06-06 00:03:20', '2603:3024:1899:3900:e0b8:6718:2aae:b70f', 'User Shahed s Bagwan logged-in successfully'),
(2083, 163, 'Logoff', '2024-06-06 03:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2084, 79, 'Login', '2024-06-07 08:03:52', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2085, 79, 'Logoff', '2024-06-07 11:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2086, 163, 'Update profile', '2024-06-09 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2087, 56, 'Login', '2024-06-09 09:04:29', '58.178.56.87', 'User Habeeb Rahman logged-in successfully'),
(2088, 56, 'Logoff', '2024-06-09 12:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2089, 79, 'Update profile', '2024-06-10 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2090, 79, 'Login', '2024-06-11 11:12:04', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2091, 79, 'Logoff', '2024-06-11 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2092, 56, 'Update profile', '2024-06-12 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2093, 79, 'Login', '2024-06-12 14:43:02', '103.179.197.94', 'User Super Admin logged-in successfully'),
(2094, 79, 'Login', '2024-06-12 14:44:36', '103.179.197.94', 'User Super Admin logged-in successfully'),
(2095, 79, 'Logoff', '2024-06-12 17:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2096, 56, 'Login', '2024-06-13 06:28:38', '157.46.135.44', 'User Habeeb Rahman logged-in successfully'),
(2097, 56, 'Logoff', '2024-06-13 09:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2098, 79, 'Update profile', '2024-06-15 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2099, 56, 'Update profile', '2024-06-16 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2100, 56, 'Login', '2024-06-16 02:46:26', '1.145.114.10', 'User Habeeb Rahman logged-in successfully'),
(2101, 56, 'Logoff', '2024-06-16 05:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2102, 56, 'Update profile', '2024-06-19 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2103, 56, 'Login', '2024-06-21 00:18:49', '2001:8004:5250:b3b9:c87b:fd35:c430:e2c9', 'User Habeeb Rahman logged-in successfully'),
(2104, 56, 'Logoff', '2024-06-21 03:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2105, 56, 'Update profile', '2024-06-24 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2106, 56, 'Login', '2024-06-25 11:34:17', '2403:4800:24dc:4301:3b67:e2d8:8ef0:e806', 'User Habeeb Rahman logged-in successfully'),
(2107, 56, 'Logoff', '2024-06-25 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2108, 56, 'Update profile', '2024-06-28 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2109, 79, 'Login', '2024-07-03 12:27:08', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2110, 79, 'Login', '2024-07-03 12:27:33', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2111, 79, 'Logoff', '2024-07-03 15:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2112, 79, 'Login', '2024-07-05 11:39:32', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2113, 176, 'Login', '2024-07-05 12:16:54', '2a02:4780:11::4f', 'User mushthaq jouhar logged-in successfully'),
(2114, 176, 'Login', '2024-07-05 12:17:33', '103.168.201.70', 'User mushthaq jouhar logged-in successfully'),
(2115, 176, 'Login', '2024-07-05 12:25:01', '103.168.201.70', 'User mushthaq jouhar logged-in successfully'),
(2116, 176, 'Login', '2024-07-05 12:44:30', '103.168.201.70', 'User mushthaq jouhar logged-in successfully'),
(2117, 176, 'Login', '2024-07-05 13:15:11', '103.168.201.70', 'User mushthaq jouhar logged-in successfully'),
(2118, 176, 'Login', '2024-07-05 13:17:03', '103.168.201.70', 'User mushthaq jouhar logged-in successfully'),
(2119, 176, 'Login', '2024-07-05 13:25:09', '103.168.201.70', 'User mushthaq jouhar logged-in successfully'),
(2120, 176, 'Login', '2024-07-05 13:26:44', '103.168.201.70', 'User mushthaq jouhar logged-in successfully'),
(2121, 79, 'Logoff', '2024-07-05 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2122, 176, 'Login', '2024-07-05 14:00:09', '103.168.201.70', 'User mushthaq jouhar logged-in successfully'),
(2123, 176, 'Login', '2024-07-05 14:01:35', '103.168.201.70', 'User mushthaq jouhar logged-in successfully'),
(2124, 79, 'Update profile', '2024-07-08 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2125, 79, 'Login', '2024-07-22 11:18:35', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2126, 79, 'Logoff', '2024-07-22 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2127, 79, 'Update profile', '2024-07-25 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2128, 79, 'Login', '2024-07-27 04:13:43', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2129, 79, 'Login', '2024-07-27 05:35:23', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2130, 79, 'Login', '2024-07-27 06:03:48', '103.147.208.144', 'User Super Admin logged-in successfully'),
(2131, 79, 'Login', '2024-07-27 06:42:53', '103.147.208.144', 'User Super Admin logged-in successfully'),
(2132, 79, 'Login', '2024-07-27 06:55:03', '103.147.208.144', 'User Super Admin logged-in successfully'),
(2133, 79, 'Logoff', '2024-07-27 09:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2134, 79, 'Update profile', '2024-07-30 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2135, 79, 'Login', '2024-08-03 10:06:45', '2401:4900:1cdc:773f:dd10:c783:c359:3fbb', 'User Super Admin logged-in successfully'),
(2136, 79, 'Logoff', '2024-08-03 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2137, 79, 'Update profile', '2024-08-06 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2138, 56, 'Login', '2024-08-15 03:10:47', '2001:8004:50d1:c1f0:863d:b37:4f13:edd4', 'User Habeeb Rahman logged-in successfully'),
(2139, 56, 'Logoff', '2024-08-15 06:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2140, 79, 'Login', '2024-08-17 02:56:49', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2141, 153, 'Login', '2024-08-17 02:58:36', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(2142, 154, 'Login', '2024-08-17 03:00:58', '2a02:4780:11::4f', 'User Tim Walker logged-in successfully'),
(2143, 79, 'Login', '2024-08-17 04:24:15', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2144, 79, 'Login', '2024-08-17 04:24:55', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2145, 163, 'Login', '2024-08-17 04:25:23', '2a02:4780:11::4f', 'User Shahed s Bagwan logged-in successfully'),
(2146, 79, 'Login', '2024-08-17 04:34:47', '2a02:4780:11::4f', 'User Super Admin logged-in successfully'),
(2147, 153, 'Logoff', '2024-08-17 05:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2148, 154, 'Logoff', '2024-08-17 06:00:04', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2149, 79, 'Logoff', '2024-08-17 07:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2150, 163, 'Logoff', '2024-08-17 07:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2151, 163, 'Login', '2024-08-17 08:06:49', '2a02:4780:11::4f', 'User Shahed s Bagwan logged-in successfully'),
(2152, 153, 'Login', '2024-08-17 10:25:07', '2a02:4780:11::4f', 'User Alison Vickers logged-in successfully'),
(2153, 154, 'Login', '2024-08-17 10:26:08', '2a02:4780:11::4f', 'User Tim Walker logged-in successfully'),
(2154, 154, 'Login', '2024-08-17 10:27:19', '61.3.220.210', 'User Tim Walker logged-in successfully'),
(2155, 163, 'Login', '2024-08-17 10:56:01', '103.151.189.72', 'User Shahed s Bagwan logged-in successfully'),
(2156, 163, 'Login', '2024-08-17 10:56:34', '2a02:4780:11::4f', 'User Shahed s Bagwan logged-in successfully'),
(2157, 153, 'Logoff', '2024-08-17 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2158, 154, 'Logoff', '2024-08-17 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2159, 163, 'Logoff', '2024-08-17 13:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2160, 56, 'Update profile', '2024-08-18 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2161, 163, 'Login', '2024-08-19 03:34:30', '103.151.188.177', 'User Shahed s Bagwan logged-in successfully'),
(2162, 79, 'Login', '2024-08-19 04:08:37', '103.151.188.177', 'User Super Admin logged-in successfully'),
(2163, 163, 'Logoff', '2024-08-19 06:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2164, 79, 'Logoff', '2024-08-19 07:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2165, 153, 'Update profile', '2024-08-20 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2166, 154, 'Update profile', '2024-08-20 00:00:02', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2167, 56, 'Login', '2024-08-21 06:55:22', '103.153.105.215', 'User Habeeb Rahman logged-in successfully'),
(2168, 56, 'Logoff', '2024-08-21 09:00:02', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2169, 79, 'Update profile', '2024-08-22 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2170, 163, 'Update profile', '2024-08-22 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2171, 56, 'Update profile', '2024-08-24 00:00:03', 'Cron Job', 'System automatically suspended the user due to too long inactivity'),
(2172, 56, 'Login', '2024-08-24 11:21:49', '2401:4900:1cde:7c:3d7c:9ab3:939a:8bac', 'User Habeeb Rahman logged-in successfully'),
(2173, 56, 'Logoff', '2024-08-24 14:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2174, 163, 'Login', '2024-08-26 04:07:24', '2a02:4780:11::4f', 'User Shahed s Bagwan logged-in successfully'),
(2175, 163, 'Login', '2024-08-26 04:07:34', '2a02:4780:11::4f', 'User Shahed s Bagwan logged-in successfully'),
(2176, 163, 'Logoff', '2024-08-26 07:00:03', 'Cron Job', 'System automatically logged off the user due to session expiry'),
(2177, 56, 'Login', '2024-08-26 14:24:26', '::1', 'User Habeeb Rahman logged-in successfully'),
(2178, 56, 'Login', '2024-08-26 14:24:57', '::1', 'User Habeeb Rahman logged-in successfully'),
(2179, 56, 'Login', '2024-08-26 14:25:29', '::1', 'User Habeeb Rahman logged-in successfully'),
(2180, 56, 'Login', '2024-08-26 14:32:32', '::1', 'User Habeeb Rahman logged-in successfully'),
(2181, 56, 'Login', '2024-08-26 14:34:21', '::1', 'User Habeeb Rahman logged-in successfully'),
(2182, 56, 'Login', '2024-08-26 14:45:47', '::1', 'User Habeeb Rahman logged-in successfully'),
(2183, 56, 'Login', '2024-08-26 16:30:07', '::1', 'User Habeeb Rahman logged-in successfully'),
(2184, 56, 'Login', '2024-08-26 16:49:02', '::1', 'User Habeeb Rahman logged-in successfully'),
(2185, 56, 'Login', '2024-08-26 17:11:09', '::1', 'User Habeeb Rahman logged-in successfully'),
(2186, 56, 'Login', '2024-08-26 17:50:16', '::1', 'User Habeeb Rahman logged-in successfully'),
(2187, 56, 'Login', '2024-08-26 19:22:46', '::1', 'User Habeeb Rahman logged-in successfully'),
(2188, 56, 'Login', '2024-08-26 19:23:03', '::1', 'User Habeeb Rahman logged-in successfully'),
(2189, 56, 'Login', '2024-08-26 19:23:15', '::1', 'User Habeeb Rahman logged-in successfully'),
(2190, 56, 'Login', '2024-08-27 17:41:00', '::1', 'User Habeeb Rahman logged-in successfully'),
(2191, 56, 'Login', '2024-08-27 17:42:28', '::1', 'User Habeeb Rahman logged-in successfully'),
(2192, 56, 'Login', '2024-08-27 21:11:04', '::1', 'User Habeeb Rahman logged-in successfully'),
(2193, 56, 'Login', '2024-08-27 21:20:24', '::1', 'User Habeeb Rahman logged-in successfully'),
(2194, 56, 'Login', '2024-08-27 21:27:46', '::1', 'User Habeeb Rahman logged-in successfully'),
(2195, 56, 'Login', '2024-08-28 09:23:18', '::1', 'User Habeeb Rahman logged-in successfully'),
(2196, 56, 'Login', '2024-08-28 09:23:34', '::1', 'User Habeeb Rahman logged-in successfully'),
(2197, 56, 'Login', '2024-08-28 09:25:08', '::1', 'User Habeeb Rahman logged-in successfully'),
(2198, 56, 'Login', '2024-08-28 10:37:55', '::1', 'User Habeeb Rahman logged-in successfully'),
(2199, 56, 'Login', '2024-08-28 10:56:02', '::1', 'User Habeeb Rahman logged-in successfully'),
(2200, 56, 'Login', '2024-08-28 11:58:56', '::1', 'User Habeeb Rahman logged-in successfully'),
(2201, 56, 'Login', '2024-08-28 13:01:06', '::1', 'User Habeeb Rahman logged-in successfully'),
(2202, 56, 'Login', '2024-08-28 15:04:45', '::1', 'User Habeeb Rahman logged-in successfully'),
(2203, 56, 'Login', '2024-08-28 16:09:37', '::1', 'User Habeeb Rahman logged-in successfully'),
(2204, 56, 'Login', '2024-08-29 09:11:33', '::1', 'User Habeeb Rahman logged-in successfully'),
(2205, 56, 'Login', '2024-08-29 09:12:14', '::1', 'User Habeeb Rahman logged-in successfully'),
(2206, 56, 'Login', '2024-08-30 11:33:45', '::1', 'User Habeeb Rahman logged-in successfully'),
(2207, 56, 'Login', '2024-08-30 13:41:49', '::1', 'User Habeeb Rahman logged-in successfully'),
(2208, 56, 'Login', '2024-08-30 14:48:30', '::1', 'User Habeeb Rahman logged-in successfully'),
(2209, 56, 'Login', '2024-08-31 15:33:50', '::1', 'User Habeeb Rahman logged-in successfully'),
(2210, 56, 'Login', '2024-08-31 18:14:45', '::1', 'User Habeeb Rahman logged-in successfully'),
(2211, 56, 'Login', '2024-08-31 19:05:38', '::1', 'User Habeeb Rahman logged-in successfully'),
(2212, 56, 'Login', '2024-08-31 19:50:41', '::1', 'User Habeeb Rahman logged-in successfully'),
(2213, 56, 'Login', '2024-08-31 20:50:59', '::1', 'User Habeeb Rahman logged-in successfully'),
(2214, 56, 'Login', '2024-08-31 21:26:02', '::1', 'User Habeeb Rahman logged-in successfully'),
(2215, 56, 'Login', '2024-09-02 10:13:09', '::1', 'User Habeeb Rahman logged-in successfully'),
(2216, 56, 'Login', '2024-09-03 17:41:28', '::1', 'User Habeeb Rahman logged-in successfully'),
(2217, 56, 'Login', '2024-09-04 10:44:22', '::1', 'User Habeeb Rahman logged-in successfully'),
(2218, 56, 'Login', '2024-09-04 13:51:28', '::1', 'User Habeeb Rahman logged-in successfully'),
(2219, 56, 'Login', '2024-09-04 14:17:59', '::1', 'User Habeeb Rahman logged-in successfully'),
(2220, 56, 'Login', '2024-09-04 15:03:20', '::1', 'User Habeeb Rahman logged-in successfully'),
(2221, 56, 'Login', '2024-09-05 09:14:01', '::1', 'User Habeeb Rahman logged-in successfully'),
(2222, 56, 'Login', '2024-09-05 09:22:55', '::1', 'User Habeeb Rahman logged-in successfully');
INSERT INTO `tbl_user_login_audit` (`userLoginAuditId`, `userProfileId`, `action`, `actionDateTime`, `deviceId`, `comments`) VALUES
(2223, 56, 'Login', '2024-09-05 18:09:55', '::1', 'User Habeeb Rahman logged-in successfully'),
(2224, 56, 'Login', '2024-09-05 18:10:17', '::1', 'User Habeeb Rahman logged-in successfully'),
(2225, 56, 'Login', '2024-09-05 18:10:58', '::1', 'User Habeeb Rahman logged-in successfully'),
(2226, 56, 'Login', '2024-09-06 10:13:01', '::1', 'User Habeeb Rahman logged-in successfully'),
(2227, 56, 'Login', '2024-09-06 10:15:25', '::1', 'User Habeeb Rahman logged-in successfully'),
(2228, 56, 'Login', '2024-09-06 10:18:19', '::1', 'User Habeeb Rahman logged-in successfully'),
(2229, 56, 'Login', '2024-09-06 10:31:03', '::1', 'User Habeeb Rahman logged-in successfully'),
(2230, 56, 'Login', '2024-09-06 10:31:36', '::1', 'User Habeeb Rahman logged-in successfully'),
(2231, 56, 'Login', '2024-09-06 10:33:13', '::1', 'User Habeeb Rahman logged-in successfully'),
(2232, 56, 'Login', '2024-09-06 10:33:22', '::1', 'User Habeeb Rahman logged-in successfully'),
(2233, 56, 'Login', '2024-09-06 10:36:09', '::1', 'User Habeeb Rahman logged-in successfully'),
(2234, 56, 'Login', '2024-09-06 10:39:40', '::1', 'User Habeeb Rahman logged-in successfully'),
(2235, 56, 'Login', '2024-09-06 10:40:11', '::1', 'User Habeeb Rahman logged-in successfully'),
(2236, 56, 'Login', '2024-09-06 15:07:49', '::1', 'User Habeeb Rahman logged-in successfully'),
(2237, 56, 'Login', '2024-09-06 16:46:34', '::1', 'User Habeeb Rahman logged-in successfully'),
(2238, 56, 'Login', '2024-09-06 17:36:46', '::1', 'User Habeeb Rahman logged-in successfully'),
(2239, 56, 'Login', '2024-09-07 12:58:13', '::1', 'User Habeeb Rahman logged-in successfully'),
(2240, 56, 'Login', '2024-09-12 15:35:12', '::1', 'User Habeeb Rahman logged-in successfully'),
(2241, 56, 'Login', '2024-09-13 11:14:16', '::1', 'User Habeeb Rahman logged-in successfully'),
(2242, 56, 'Login', '2024-09-13 17:16:33', '::1', 'User Habeeb Rahman logged-in successfully'),
(2243, 56, 'Login', '2024-09-15 09:00:47', '::1', 'User Habeeb Rahman logged-in successfully'),
(2244, 56, 'Login', '2024-09-15 10:17:37', '::1', 'User Habeeb Rahman logged-in successfully'),
(2245, 56, 'Login', '2024-09-15 10:17:41', '::1', 'User Habeeb Rahman logged-in successfully'),
(2246, 56, 'Login', '2024-09-15 15:01:28', '::1', 'User Habeeb Rahman logged-in successfully'),
(2247, 56, 'Login', '2024-09-18 18:01:44', '::1', 'User Habeeb Rahman logged-in successfully'),
(2248, 56, 'Login', '2024-09-19 08:57:31', '::1', 'User Habeeb Rahman logged-in successfully'),
(2249, 56, 'Login', '2024-09-19 14:16:54', '::1', 'User Habeeb Rahman logged-in successfully'),
(2250, 56, 'Login', '2024-09-20 17:41:34', '::1', 'User Habeeb Rahman logged-in successfully'),
(2251, 56, 'Login', '2024-09-21 15:45:58', '::1', 'User Habeeb Rahman logged-in successfully'),
(2252, 56, 'Login', '2024-10-01 11:48:21', '::1', 'User Habeeb Rahman logged-in successfully'),
(2253, 56, 'Login', '2024-10-05 14:10:35', '::1', 'User Habeeb Rahman logged-in successfully'),
(2254, 56, 'Login', '2024-10-07 08:00:35', '::1', 'User Habeeb Rahman logged-in successfully'),
(2255, 56, 'Login', '2024-11-06 09:51:36', '::1', 'User Habeeb Rahman logged-in successfully'),
(2256, 56, 'Login', '2024-11-06 17:59:44', '::1', 'User Habeeb Rahman logged-in successfully'),
(2257, 56, 'Login', '2024-11-07 08:14:56', '::1', 'User Habeeb Rahman logged-in successfully'),
(2258, 56, 'Login', '2024-11-07 11:19:36', '::1', 'User Habeeb Rahman logged-in successfully'),
(2259, 56, 'Login', '2024-11-11 09:47:18', '::1', 'User Habeeb Rahman logged-in successfully'),
(2260, 56, 'Login', '2024-11-11 16:18:22', '::1', 'User Habeeb Rahman logged-in successfully'),
(2261, 56, 'Login', '2024-11-12 09:18:03', '::1', 'User Habeeb Rahman logged-in successfully'),
(2262, 56, 'Login', '2024-11-12 21:42:39', '::1', 'User Habeeb Rahman logged-in successfully'),
(2263, 56, 'Login', '2024-11-13 09:06:19', '::1', 'User Habeeb Rahman logged-in successfully'),
(2264, 56, 'Login', '2024-11-21 09:58:37', '::1', 'User Habeeb Rahman logged-in successfully'),
(2265, 56, 'Login', '2024-11-22 08:22:21', '::1', 'User Habeeb Rahman logged-in successfully'),
(2266, 56, 'Login', '2024-11-22 10:12:27', '::1', 'User Habeeb Rahman logged-in successfully'),
(2267, 56, 'Login', '2024-11-22 10:52:38', '::1', 'User Habeeb Rahman logged-in successfully'),
(2268, 56, 'Login', '2024-11-22 13:36:42', '::1', 'User Habeeb Rahman logged-in successfully'),
(2269, 56, 'Login', '2024-11-26 14:26:58', '::1', 'User Habeeb Rahman logged-in successfully'),
(2270, 56, 'Login', '2024-11-27 11:22:13', '::1', 'User Habeeb Rahman logged-in successfully'),
(2271, 56, 'Login', '2024-11-30 11:44:52', '::1', 'User Habeeb Rahman logged-in successfully'),
(2272, 56, 'Login', '2024-12-02 10:23:49', '::1', 'User Habeeb Rahman logged-in successfully'),
(2273, 177, 'Login', '2025-01-05 08:31:09', '::1', 'User mushthaque tccc jouhar logged-in successfully'),
(2274, 178, 'Login', '2025-01-06 18:07:59', '::1', 'User mushthaque mtc jouhar logged-in successfully'),
(2275, 178, 'Login', '2025-01-06 18:11:24', '::1', 'User mushthaque mtc jouhar logged-in successfully'),
(2276, 56, 'Login', '2025-01-27 14:31:13', '::1', 'User Habeeb Rahman logged-in successfully'),
(2277, 56, 'Login', '2025-01-30 16:07:32', '::1', 'User Habeeb Rahman logged-in successfully'),
(2278, 56, 'Login', '2025-01-30 16:08:03', '::1', 'User Habeeb Rahman logged-in successfully'),
(2279, 56, 'Login', '2025-01-30 16:08:08', '::1', 'User Habeeb Rahman logged-in successfully'),
(2280, 56, 'Login', '2025-02-06 11:07:07', '::1', 'User Habeeb Rahman logged-in successfully'),
(2281, 1, 'Login', '2025-06-05 16:55:51', '::1', 'User Softometric solutions logged-in successfully');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_profiles`
--

CREATE TABLE `tbl_user_profiles` (
  `userProfileId` int(11) NOT NULL,
  `firstName` varchar(50) DEFAULT NULL,
  `middleName` varchar(50) DEFAULT NULL,
  `lastName` varchar(50) NOT NULL,
  `dateOfBirth` date DEFAULT NULL,
  `addressLine1` varchar(300) NOT NULL,
  `addressLine2` varchar(300) DEFAULT NULL,
  `stateId` int(11) NOT NULL,
  `countryId` int(11) NOT NULL,
  `zipOrPostCode` varchar(20) NOT NULL,
  `email` varchar(50) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `password` varchar(256) NOT NULL,
  `statusId` int(11) NOT NULL,
  `userTypeId` int(11) NOT NULL,
  `userProfileModifiedDateTime` datetime NOT NULL DEFAULT current_timestamp(),
  `user_photo` varchar(255) DEFAULT NULL,
  `ipAddress` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_user_profiles`
--

INSERT INTO `tbl_user_profiles` (`userProfileId`, `firstName`, `middleName`, `lastName`, `dateOfBirth`, `addressLine1`, `addressLine2`, `stateId`, `countryId`, `zipOrPostCode`, `email`, `phone`, `mobile`, `password`, `statusId`, `userTypeId`, `userProfileModifiedDateTime`, `user_photo`, `ipAddress`) VALUES
(1, 'Softometric', '', 'solutions', NULL, 'Calicut', '', 40, 76, '673014', 'softometric@gmail.com', '35677349856', '3335577812', '$2y$10$nfStzJi./TafjgcPJGB6nev0kJtAuAAWJjLF9NTyjKQVpTRXdkwiq', 1, 1, '2025-06-05 16:55:51', NULL, '103.179.196.185');

--
-- Triggers `tbl_user_profiles`
--
DELIMITER $$
CREATE TRIGGER `tr_validate_user_profiles_delete` BEFORE DELETE ON `tbl_user_profiles` FOR EACH ROW BEGIN
	DECLARE result INT;
   	SELECT fn_validate_tbl_user_profiles_delete(OLD.userProfileId) INTO result;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_validate_user_profiles_insert` BEFORE INSERT ON `tbl_user_profiles` FOR EACH ROW BEGIN
	DECLARE result INT;
   	SELECT fn_validate_tbl_user_profiles_insert_update(NEW.stateId,NEW.countryId) INTO result;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_validate_user_profiles_update` BEFORE UPDATE ON `tbl_user_profiles` FOR EACH ROW BEGIN
	IF NEW.countryId != OLD.countryId OR  NEW.stateId != OLD.stateId THEN
    BEGIN
    	DECLARE result INT;
   	 	SELECT fn_validate_tbl_user_profiles_insert_update(NEW.stateId,NEW.countryId) INTO result;
    END;
    END IF;     
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_roles`
--

CREATE TABLE `tbl_user_roles` (
  `userProfileId` int(11) NOT NULL,
  `roleId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_user_roles`
--

INSERT INTO `tbl_user_roles` (`userProfileId`, `roleId`) VALUES
(1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_types`
--

CREATE TABLE `tbl_user_types` (
  `userTypeId` int(11) NOT NULL,
  `userType` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_user_types`
--

INSERT INTO `tbl_user_types` (`userTypeId`, `userType`) VALUES
(1, 'Corporate'),
(2, 'User');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_brand`
--
ALTER TABLE `tbl_brand`
  ADD PRIMARY KEY (`brandId`),
  ADD KEY `categoryId` (`categoryId`);

--
-- Indexes for table `tbl_category`
--
ALTER TABLE `tbl_category`
  ADD PRIMARY KEY (`categoryId`);

--
-- Indexes for table `tbl_countries`
--
ALTER TABLE `tbl_countries`
  ADD PRIMARY KEY (`countryId`),
  ADD UNIQUE KEY `countryName` (`countryName`);

--
-- Indexes for table `tbl_email_verification`
--
ALTER TABLE `tbl_email_verification`
  ADD PRIMARY KEY (`emailVerificationId`);

--
-- Indexes for table `tbl_notifications`
--
ALTER TABLE `tbl_notifications`
  ADD PRIMARY KEY (`notificationId`),
  ADD KEY `userProfileId` (`userProfileId`);

--
-- Indexes for table `tbl_permissions`
--
ALTER TABLE `tbl_permissions`
  ADD PRIMARY KEY (`permissionId`),
  ADD UNIQUE KEY `permissionName` (`permissionName`);

--
-- Indexes for table `tbl_product`
--
ALTER TABLE `tbl_product`
  ADD PRIMARY KEY (`productId`),
  ADD KEY `brandId` (`brandId`),
  ADD KEY `categoryId` (`categoryId`);

--
-- Indexes for table `tbl_resources`
--
ALTER TABLE `tbl_resources`
  ADD PRIMARY KEY (`resourceId`);

--
-- Indexes for table `tbl_roles`
--
ALTER TABLE `tbl_roles`
  ADD PRIMARY KEY (`roleId`),
  ADD UNIQUE KEY `roleName` (`roleName`);

--
-- Indexes for table `tbl_role_groups`
--
ALTER TABLE `tbl_role_groups`
  ADD UNIQUE KEY `userTypeId` (`userTypeId`,`roleId`),
  ADD KEY `roleId` (`roleId`);

--
-- Indexes for table `tbl_role_permissions`
--
ALTER TABLE `tbl_role_permissions`
  ADD UNIQUE KEY `roleId` (`roleId`,`permissionId`),
  ADD KEY `permissionId` (`permissionId`);

--
-- Indexes for table `tbl_states`
--
ALTER TABLE `tbl_states`
  ADD PRIMARY KEY (`stateId`),
  ADD UNIQUE KEY `stateName` (`stateName`),
  ADD KEY `countryId` (`countryId`);

--
-- Indexes for table `tbl_status`
--
ALTER TABLE `tbl_status`
  ADD PRIMARY KEY (`statusId`),
  ADD UNIQUE KEY `status` (`status`);

--
-- Indexes for table `tbl_user_login_audit`
--
ALTER TABLE `tbl_user_login_audit`
  ADD PRIMARY KEY (`userLoginAuditId`),
  ADD KEY `userProfileId` (`userProfileId`);

--
-- Indexes for table `tbl_user_profiles`
--
ALTER TABLE `tbl_user_profiles`
  ADD PRIMARY KEY (`userProfileId`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `countryId` (`countryId`),
  ADD KEY `stateId` (`stateId`),
  ADD KEY `userTypeId` (`userTypeId`),
  ADD KEY `statusId` (`statusId`);

--
-- Indexes for table `tbl_user_roles`
--
ALTER TABLE `tbl_user_roles`
  ADD UNIQUE KEY `userProfileId` (`userProfileId`,`roleId`),
  ADD KEY `roleId` (`roleId`);

--
-- Indexes for table `tbl_user_types`
--
ALTER TABLE `tbl_user_types`
  ADD PRIMARY KEY (`userTypeId`),
  ADD UNIQUE KEY `userType` (`userType`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_notifications`
--
ALTER TABLE `tbl_notifications`
  MODIFY `notificationId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `tbl_states`
--
ALTER TABLE `tbl_states`
  MODIFY `stateId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=868;

--
-- AUTO_INCREMENT for table `tbl_status`
--
ALTER TABLE `tbl_status`
  MODIFY `statusId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `tbl_user_types`
--
ALTER TABLE `tbl_user_types`
  MODIFY `userTypeId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tbl_brand`
--
ALTER TABLE `tbl_brand`
  ADD CONSTRAINT `tbl_brand_ibfk_1` FOREIGN KEY (`categoryId`) REFERENCES `tbl_category` (`categoryId`);

--
-- Constraints for table `tbl_notifications`
--
ALTER TABLE `tbl_notifications`
  ADD CONSTRAINT `tbl_notifications_ibfk_1` FOREIGN KEY (`userProfileId`) REFERENCES `tbl_user_profiles` (`userProfileId`);

--
-- Constraints for table `tbl_product`
--
ALTER TABLE `tbl_product`
  ADD CONSTRAINT `tbl_product_ibfk_1` FOREIGN KEY (`brandId`) REFERENCES `tbl_brand` (`brandId`),
  ADD CONSTRAINT `tbl_product_ibfk_2` FOREIGN KEY (`categoryId`) REFERENCES `tbl_category` (`categoryId`);

--
-- Constraints for table `tbl_role_groups`
--
ALTER TABLE `tbl_role_groups`
  ADD CONSTRAINT `tbl_role_groups_ibfk_1` FOREIGN KEY (`userTypeId`) REFERENCES `tbl_user_types` (`userTypeId`),
  ADD CONSTRAINT `tbl_role_groups_ibfk_2` FOREIGN KEY (`roleId`) REFERENCES `tbl_roles` (`roleId`);

--
-- Constraints for table `tbl_role_permissions`
--
ALTER TABLE `tbl_role_permissions`
  ADD CONSTRAINT `tbl_role_permissions_ibfk_3` FOREIGN KEY (`permissionId`) REFERENCES `tbl_permissions` (`permissionId`),
  ADD CONSTRAINT `tbl_role_permissions_ibfk_4` FOREIGN KEY (`roleId`) REFERENCES `tbl_roles` (`roleId`);

--
-- Constraints for table `tbl_states`
--
ALTER TABLE `tbl_states`
  ADD CONSTRAINT `tbl_states_ibfk_1` FOREIGN KEY (`countryId`) REFERENCES `tbl_countries` (`countryId`);

--
-- Constraints for table `tbl_user_profiles`
--
ALTER TABLE `tbl_user_profiles`
  ADD CONSTRAINT `tbl_user_profiles_ibfk_1` FOREIGN KEY (`countryId`) REFERENCES `tbl_countries` (`countryId`),
  ADD CONSTRAINT `tbl_user_profiles_ibfk_2` FOREIGN KEY (`stateId`) REFERENCES `tbl_states` (`stateId`),
  ADD CONSTRAINT `tbl_user_profiles_ibfk_3` FOREIGN KEY (`userTypeId`) REFERENCES `tbl_user_types` (`userTypeId`),
  ADD CONSTRAINT `tbl_user_profiles_ibfk_4` FOREIGN KEY (`statusId`) REFERENCES `tbl_status` (`statusId`);

--
-- Constraints for table `tbl_user_roles`
--
ALTER TABLE `tbl_user_roles`
  ADD CONSTRAINT `tbl_user_roles_ibfk_2` FOREIGN KEY (`roleId`) REFERENCES `tbl_roles` (`roleId`),
  ADD CONSTRAINT `tbl_user_roles_ibfk_3` FOREIGN KEY (`userProfileId`) REFERENCES `tbl_user_profiles` (`userProfileId`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
