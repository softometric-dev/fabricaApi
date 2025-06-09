<?php

namespace App\Models;

use CodeIgniter\Model;
use App\Libraries\{
    AuthenticationException,
    AuthToken
};

use App\Models\Common\DataModels\{
    UserProfileDataModel,
    RoleDataModel,
    PermissionDataModel,
    
};
use App\Models\Common\Base_model;
use App\Libraries\DatabaseException as Cust_DatabaseException;
use CodeIgniter\Database\Exceptions\DatabaseException;

class AuthService_model extends Base_model
{
    protected $db;

    public function __construct()
    {
        parent::__construct();
        $this->authToken = new AuthToken();
        $this->db = \Config\Database::connect();
    }

    function loginProc($loginRequestDataModel)
		{	
			$user = $loginRequestDataModel->user;
            $authInfo = $loginRequestDataModel->authInfo;
         
            $sql1 = "CALL sp_getUserProfileByEmail(?)";
            try {
             $query1 = $this->db->query($sql1, [$user->email]);
            
            } catch (DatabaseException $e) {
                $this->checkDBError();
            }

            $resultSet1 = UserProfileDataModel::fromDbResultSet($query1->getResultArray());
            $userProfile = count($resultSet1) > 0 ? $resultSet1[0] : null;
        
            if ($userProfile === null || !password_verify($user->password, $userProfile->password)) {
               
                throw new AuthenticationException(INVALID_CREDENTIALS_ERROR);
            }

            if ($userProfile->status->statusId == STATUS_DISABLED) {
                throw new AuthenticationException(ACCOUNT_DISABLED_ERROR);
            }

            // Free the result object
            $this->db->simpleQuery('SELECT 1');
            $query1->freeResult();
            
            $sql2 = "CALL sp_updateUserProfile(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            try {
                $query2 = $this->db->query($sql2, [
                    $userProfile->userProfileId,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    $userProfile->status->statusId,
                    null,
                    null,
                    $userProfile->lastModifiedDateTime,
                    null
                ]);

            
            } catch (DatabaseException $e) {
                $this->checkDBError();
            }

            // Free the result object
            $this->db->simpleQuery('SELECT 1');
            $query2->freeResult();

            $sql3 = "CALL sp_createUserAuditLog(?,?,?,?)";
            try {
                $query3 = $this->db->query($sql3, [
                    $userProfile->userProfileId,
                    "Login",
                    $authInfo->remoteAddress,
                    "User " . $userProfile->firstName . " " . $userProfile->lastName . " logged-in successfully"
                ]);
            } catch (DatabaseException $e) {
                $this->checkDBError();
            }
            
            
            return $userProfile;
		}

    public function impersonateUserProc($impersonateUserRequestDataModel)
    {
        // Similar structure as loginProc() with adjustments for impersonation logic
        // Refer to the loginProc method above for structure
    }

    public function logoffProc($logoffRequestDataModel)
    {
        $user = $logoffRequestDataModel->user;
        $authInfo = $logoffRequestDataModel->authInfo;
        $userProfileId = $authInfo->getUserProfileId();

        // Call stored procedure to update user profile status
        $sql1 = "CALL sp_updateUserProfile(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        $this->db->query($sql1, [
            $userProfileId,
            null, null, null, null, null, null, null,
            null, null, null, null, null,
            $user->status->statusId, null,null
        ]);

        // Move to the next result set
        $this->db->simpleQuery('SELECT 1');

        // Call stored procedure to get user profile by ID
        $sql2 = "CALL sp_getUserProfileByUserProfileId(?)";
        $query2 = $this->db->query($sql2, [$userProfileId]);

        $resultSet2 = UserProfileDataModel::fromDbResultSet($query2->getResult());
        $userProfile = count($resultSet2) > 0 ? $resultSet2[0] : null;

        $query2->freeResult();

        // Call stored procedure to create user audit log
        $sql3 = "CALL sp_createUserAuditLog(?,?,?,?)";
        $this->db->query($sql3, [
            $userProfile->userProfileId,
            "Logoff",
            $authInfo->remoteAddress,
            "User {$userProfile->firstName} {$userProfile->lastName} logged-off successfully"
        ]);

        return $userProfile;
    }

    public function refreshTokenProc($refreshTokenRequestDataModel)
    {   
      
        // $userProfileId = 56;
      
        $this->authToken->validateToken();

        $userProfileId = $this->authToken->authInfo->payload->sub;
        
     
        // Call stored procedure to get user profile by ID
        $sql1 = "CALL sp_getUserProfileByUserProfileId(?)";
        $query1 = $this->db->query($sql1, [$userProfileId]);

        $resultSet1 = UserProfileDataModel::fromDbResultSet($query1->getResult());
        $userProfile = count($resultSet1) > 0 ? $resultSet1[0] : null;

        if ($userProfile == null) {
            throw new AuthenticationException(INVALID_CREDENTIALS_ERROR);
        }

        return $userProfile;
    }

    public function hasPermissionProc($hasPermissionRequestDataModel, &$hasPermissionResponseDataModel)
    {
        $permissionsToCheck = $hasPermissionRequestDataModel->permissions;
        $requireAll = $hasPermissionRequestDataModel->requireAll;
        $authInfo = $hasPermissionRequestDataModel->authInfo;

        $userProfileId = $authInfo->getUserProfileId();

        // Call stored procedure to get user permissions by user profile ID
        $sql = "CALL sp_getUserPermissionsByUserProfileId(?)";
        $query = $this->db->query($sql, [$userProfileId]);

        $permissions = PermissionDataModel::fromDbResultSet($query->getResult());
        $permissionsMatched = [];
   
           
        foreach ($permissionsToCheck as $permissionToCheck) {
            $isExist = false;
            foreach ($permissions as $permission) {
            //     $permissionIdOrNameToCheck = (empty($permissionToCheck->permissionId)) 
            //     ? $permissionToCheck->permissionName 
            //     : $permissionToCheck->permissionId;
            
            // $permissionIdOrNameFromDb = (empty($permission->permissionId)) 
            //     ? $permission->permissionName 
            //     : $permission->permissionId;
            if (empty($permissionToCheck->permissionId)) {
                $permissionIdOrNameToCheck =  $permissionToCheck->permissionName;
                $permissionIdOrNameFromDb =  $permission->permissionName;
            } else {
                $permissionIdOrNameToCheck =  $permissionToCheck->permissionId;
                $permissionIdOrNameFromDb =  $permission->permissionId;
            }

                if (strtolower(trim($permissionIdOrNameToCheck)) === strtolower(trim($permissionIdOrNameFromDb))) {
                    $permissionsMatched[] = $permissionIdOrNameFromDb;
                    break;
                }
            }
        }

        if ($requireAll) {
            $hasPermissionResponseDataModel->hasPermission = count($permissionsToCheck) === count($permissionsMatched);
        } else {
            $hasPermissionResponseDataModel->hasPermission = count($permissionsMatched) > 0;
        }
    }

    // private function checkDBError()
    // {
    //     if ($this->db->error()['code']) {
    //         throw new DatabaseException($this->db->error()['message']);
    //     }
    // }
}
