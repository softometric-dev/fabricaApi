<?php

namespace App\Models;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\PermissionDataModel;
use App\Models\Common\DataModels\UserTypeDataModel;
use App\Models\Common\DataModels\StatusDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\FranchiseeDataModel;
use App\Models\Common\DataModels\StatisticsDataModel;
use App\Models\Common\DataModels\UserAuditLogDataModel;
use App\Models\Common\DataModels\DealerDataModel;
use App\Models\Common\DataModels\VerifyEmailDataModel;
use App\Models\Common\ApiResponseDataModel;
use App\Models\Common\Base_model;
use CodeIgniter\Database\Exceptions\DatabaseException;
use App\Libraries\{VerificationCodeException,InvalidUserException};
use App\Libraries\DatabaseException as Cust_DatabaseException;

class IDAMService_model extends Base_model
{

    public function __construct()
    {
        parent::__construct();
    }

    function createUserProc($createUserRequestDataModel, &$createUserResponseDataModel)
    {

        $newUser = $createUserRequestDataModel->newUser;
        $role = $createUserRequestDataModel->role;

        $sql1 = "CALL sp_createUserProfile(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try {
            $query1 = $this->db->query($sql1, [
                $newUser->firstName,
                $newUser->middleName,
                $newUser->lastName,
                $newUser->dateOfBirth,
                $newUser->address->addressLine1,
                $newUser->address->addressLine2,
                $newUser->address->state->stateId,
                $newUser->address->country->countryId,
                $newUser->address->zipOrPostCode,
                $newUser->email,
                $newUser->phone,
                $newUser->mobile,
                password_hash($newUser->password, PASSWORD_DEFAULT),
                $newUser->status->statusId,
                $newUser->userType->userTypeId,
                $role->roleId,
                $newUser->ipAddress,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
            // Handle the exception
        }
        // Fetch the result as an array of objects or arrays
        $resultSet1 = UserProfileDataModel::fromDbResultSet($query1->getResultArray());
   
        $createUserResponseDataModel->newUser = count($resultSet1) > 0 ? $resultSet1[0] : null;

        if ($createUserResponseDataModel->newUser != null) {

            mysqli_next_result($this->db->connID);

            $nextResultSet = mysqli_store_result($this->db->connID);
            $rolesResult = $nextResultSet->fetch_all(MYSQLI_ASSOC);
            $resultSet2 = RoleDataModel::fromDbResultSet($rolesResult);
            $createUserResponseDataModel->newUser->roles = count($resultSet2) > 0 ? $resultSet2 : null;
        }
    }
 
    function registerUserProc($registerUserRequestDataModel, &$registerUserResponseDataModel)
    {

        $newUser = $registerUserRequestDataModel->newUser;
        $role = $registerUserRequestDataModel->role;
        $confirmCode = $registerUserRequestDataModel->confirmCode;
 
        $sql2 = "CALL sp_getVerifyEmailByEmailAndCode(?,?)";
        try {
            $query2 = $this->db->query($sql2, [
                $newUser->email,
                $confirmCode->verificationCode,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
            // Handle the exception
        }
     

        $resultSet2 = VerifyEmailDataModel::fromDbResultSet($query2->getResultArray());

        if (empty($resultSet2)) {
            throw new VerificationCodeException(INVALID_VERIFICATION_CODE_ERROR);
        }
        
        $registerUserResponseDataModel->confirmCode = count($resultSet2) > 0 ? $resultSet2[0] : null;
     
        if($registerUserResponseDataModel->confirmCode !=null){

           $sql1 = "CALL sp_createUserProfile(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try {
           $query1 = $this->db->query($sql1, [
            $newUser->firstName,
            $newUser->middleName,
            $newUser->lastName,
            $newUser->dateOfBirth,
            $newUser->address->addressLine1,
            $newUser->address->addressLine2,
            $newUser->address->state->stateId,
            $newUser->address->country->countryId,
            $newUser->address->zipOrPostCode,
            $newUser->email,
            $newUser->phone,
            $newUser->mobile,
            password_hash($newUser->password, PASSWORD_DEFAULT),
            $newUser->status->statusId,
            $newUser->userType->userTypeId,
            $role->roleId,
            $newUser->ipAddress
            
        ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
            // Handle the exception
        }

        // Fetch the result as an array of objects or arrays
        $resultSet1 = UserProfileDataModel::fromDbResultSet($query1->getResultArray());
   
        $registerUserResponseDataModel->newUser = count($resultSet1) > 0 ? $resultSet1[0] : null;

            if ($registerUserResponseDataModel->newUser != null) {

                mysqli_next_result($this->db->connID);

                $nextResultSet = mysqli_store_result($this->db->connID);
                $rolesResult = $nextResultSet->fetch_all(MYSQLI_ASSOC);
                $resultSet2 = RoleDataModel::fromDbResultSet($rolesResult);
                $registerUserResponseDataModel->newUser->roles = count($resultSet2) > 0 ? $resultSet2 : null;

                $sql = "CALL sp_deleteVerifiedEmailByEmail(?)";
                $query = $this->db->query($sql, [
                    $registerUserResponseDataModel->newUser->email
                ]);
            }

            if ($registerUserResponseDataModel->newUser) {
        
                $userProfileId = $registerUserResponseDataModel->newUser->userProfileId ?? '';
                $firstName = $registerUserResponseDataModel->newUser->firstName ?? '';
                $lastName = $registerUserResponseDataModel->newUser->lastName ?? '';
                $type="Auth_Notifications";
            
                // Updated notification message with first name and last name
                $notificationMessage = "Welcome to ABL Connect, $firstName $lastName! Get started now and unlock exciting rewards.";
            
                $sql3 = "CALL sp_createNotification(?, ?, ?,?,?)";
                try {
                    $query3 = $this->db->query($sql3, [
                        $userProfileId, // Assuming this is the intended recipient
                        $notificationMessage,
                        0, // Notification status (e.g., unread)
                        $type,
                        $userProfileId,

                    ]);
                } catch (DatabaseException $e) {
                    $this->checkDBError();
                    // Handle the exception
                }
    
            }

        }
        else{
            $registerUserResponseDataModel->message ="verification Failed";
        }
        
    }

    function updateUserProc($updateUserRequestDataModel, &$updateUserResponseDataModel)
    {

        $userProfile = $updateUserRequestDataModel->user;
        $stateId = !empty($userProfile->address) && !empty($userProfile->address->state) ? $userProfile->address->state->stateId : null;
        $addressLine1 = !empty($userProfile->address) ? $userProfile->address->addressLine1 : null;
        $addressLine2 = !empty($userProfile->address) ? $userProfile->address->addressLine2 : null;
        $zipOrPostCode = !empty($userProfile->address) ? $userProfile->address->zipOrPostCode : null;
        $countryId = !empty($userProfile->address) && !empty($userProfile->address->country) ? $userProfile->address->country->countryId : null;
        $statusId = !empty($userProfile->status) ? $userProfile->status->statusId : null;
        $password = !empty($userProfile->password) ? password_hash($userProfile->password, PASSWORD_DEFAULT) : null;
        $userTypeId = !empty($userProfile->userType) ? $userProfile->userType->userTypeId : null;
        $roleId = !empty($updateUserRequestDataModel->role) ? $updateUserRequestDataModel->role->roleId : null;
        $ipAddress = !empty($userProfile->ipAddress) ? $userProfile->ipAddress : null;
        
        $sql1 = "CALL sp_updateUserProfile(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try {
            $query1 = $this->db->query($sql1, [
                $userProfile->userProfileId,
                $userProfile->firstName,
                $userProfile->middleName,
                $userProfile->lastName,
                $userProfile->dateOfBirth,
                $addressLine1,
                $addressLine2,
                $stateId,
                $countryId,
                $zipOrPostCode,
                $userProfile->email,
                $userProfile->phone,
                $userProfile->mobile,
                $password,
                $statusId,
                $userTypeId,
                $roleId,
                $userProfile->lastModifiedDateTime,
                $ipAddress
            ]);
            } catch (DatabaseException $e) {
                $this->checkDBError();
            }

        // Free the result object
        $this->db->connID->next_result();
        $query1->freeResult();

        $sql2 = "CALL sp_getUserProfileByUserProfileId(?)";
        try {
            $query2 = $this->db->query($sql2, [
                $userProfile->userProfileId
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet1 = UserProfileDataModel::fromDbResultSet($query2->getResultArray());
        $updateUserResponseDataModel->user = count($resultSet1) > 0 ? $resultSet1[0] : null;

        if ($updateUserResponseDataModel->user != null) {

            mysqli_next_result($this->db->connID);

            $nextResultSet = mysqli_store_result($this->db->connID);
            $rolesResult = $nextResultSet->fetch_all(MYSQLI_ASSOC);
            $resultSet2 = RoleDataModel::fromDbResultSet($rolesResult);
            $updateUserResponseDataModel->user->roles = count($resultSet2) > 0 ? $resultSet2 : null;

        }


    }

    public function upload_and_update_user($user_id, $photo_data)
    {
        $photo_path = $this->upload_user_photo($photo_data);

        if ($photo_path) {
            $data = array(
                'user_photo' => $photo_path,
            );

            $this->db->where('userProfileId', $user_id);

            $update_result = $this->db->update('tbl_user_profiles', $data);

            if ($update_result !== false) {
                // Check if affected rows are greater than 0 to ensure update occurred
                if ($this->db->affected_rows() > 0) {
                    return true; // Update successful
                } else {
                    // No rows affected, possibly user_id not found
                    return false;
                }
            } else {
                // Handle database update error
                return false;
            }
        } else {
            // Handle photo upload error
            return false;
        }
    }

    private function upload_user_photo($photo_data)
    {
        $config['upload_path'] = './uploads';
        // $config['upload_path'] = '/var/www/html/api/IDAMServiceApi/uploads';
        // $config['upload_path'] = './uploads/';
        $config['allowed_types'] = 'jpg|jpeg|png|gif';
        $config['max_size'] = 2048;

        $this->load->library('upload', $config);

        if ($this->upload->do_upload('user_photo')) {
            return 'uploads/' . $this->upload->data('file_name');
        } else {
            return false;
        }
    }

    function updateUserWithPhotoProc($updateUserRequestDataModel, $userPhotoUrl, &$updateUserResponseDataModel)
    {
        $userProfile = $updateUserRequestDataModel->user;

        // Update other user profile fields in the database...

        // Update the user's profile including the user_photo field
        $sql = "UPDATE 	 SET user_photo = ? WHERE userProfileId = ?";
        $this->db->query($sql, array($userPhotoUrl, $userProfile->userProfileId));
        $this->checkDBError();

        // Fetch the updated user profile details
        $this->IDAMService_model->getUserProc($updateUserRequestDataModel, $updateUserResponseDataModel);
    }

    function getUserProc($getUserRequestDataModel, &$getUserResponseDataModel)
    {
        $user = $getUserRequestDataModel->user;

        $sql = "CALL sp_getUserProfileByUserProfileId(?)";
        $query = $this->db->query($sql, [$user->userProfileId]);

        $this->checkDBError();

        // Fetch the result as an array of objects or arrays
        $resultSet1 = UserProfileDataModel::fromDbResultSet($query->getResultArray());
        $getUserResponseDataModel->user = count($resultSet1) > 0 ? $resultSet1[0] : null;

        if ($getUserResponseDataModel->user != null) {
            // Move to the next result set
            mysqli_next_result($this->db->connID);

            $nextResultSet = mysqli_store_result($this->db->connID);
            $rolesResult = $nextResultSet->fetch_all(MYSQLI_ASSOC);
            $resultSet2 = RoleDataModel::fromDbResultSet($rolesResult);
            $getUserResponseDataModel->user->roles = count($resultSet2) > 0 ? $resultSet2 : null;
        }
    }

   
    function forgotPasswordProc($forgotPasswordRequestDataModel, &$forgotPasswordResponseDatamodel)
    {
        $passwordForgot = $forgotPasswordRequestDataModel->passwordForgot;
        if(!empty( $passwordForgot->email)){

            $sql = "CALL sp_getUserProfileByEmail(?)";
            try {
             $query = $this->db->query($sql, [$passwordForgot->email]);
            } catch (DatabaseException $e) {
                $this->checkDBError();
            }
    
            $resultSet1 = UserProfileDataModel::fromDbResultSet($query->getResultArray());

            if (empty($resultSet1)) {
                throw new InvalidUserException(INVALID_USER_ERROR);
            }
            if(count($resultSet1) >0){

                $email = $passwordForgot->email;
                $userProfileId = $resultSet1[0]->userProfileId;
                $lastModifiedDateTime = $resultSet1[0]->lastModifiedDateTime;
                $passwordLength = 10; // You can adjust the length as needed
				$passwordCharacters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
				$generatedPassword = substr(str_shuffle($passwordCharacters), 0, $passwordLength);
				$password = $generatedPassword;

                $sql1 = "CALL sp_updateUserProfile(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                try {
                    $query1 = $this->db->query($sql1, [
                    $userProfileId,
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
                    password_hash($password, PASSWORD_DEFAULT),
                    null,
                    null,
                    null,
                    $lastModifiedDateTime,
                    null
                    ]);
            } catch (DatabaseException $e) {
                $this->checkDBError();
            }
        

                if ($this->sendPasswordResetEmail($email, $password, $userProfileId)) {
                    $forgotPasswordResponseDatamodel->message = 'Password reset email sent successfully.';
                    $forgotPasswordResponseDatamodel->passwordForgot = 'Password reset email sent successfully.';
                } else {
                    $forgotPasswordResponseDatamodel->message = 'Failed to send password reset email.';
                    $forgotPasswordResponseDatamodel->passwordForgot = 'Failed to send password reset email';
                }
                // $this->sendPasswordResetEmail($email, $password, $userProfileId);
            }
            else{
                $forgotPasswordResponseDatamodel->passwordForgot = "Invalid user. No user found with this email.";
            }
           
        }
    }

    // private function generateRandomValue()
    // {
    //     // Define the character pool
    //     $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()';
        
    //     // Shuffle the characters and pick a random subset of 12
    //     return substr(str_shuffle(str_repeat($characters, 5)), 0, 12);
    // }
  
    private function generateRandomValue()
    {
        // Generate a random 6-digit number
        return substr(str_shuffle(str_repeat('0123456789', 3)), 0, 6);
    }

    function verifyEmailProc($verifyEmailRequestDataModel, &$verifyEmailResponseDataModel)
    {
        $verifyEmail = $verifyEmailRequestDataModel->verifyEmail;
        $randomNumber = $this->generateRandomValue();

        $sql1 = "CALL sp_addVerifyEmail(?,?)";
        try {

            $query1 = $this->db->query($sql1, [
                $verifyEmail->email,
                $randomNumber,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet1 = VerifyEmailDataModel::fromDbResultSet($query1->getResultArray());
   
        $verifyEmailResponseDataModel->verifyEmail = count($resultSet1) > 0 ? $resultSet1[0] : null;

        if ($verifyEmailResponseDataModel->verifyEmail != null) {

            $email=$verifyEmailResponseDataModel->verifyEmail->email;
            $code=$randomNumber;

            if ($this->sendMailVerificationEmail($email, $code,)) {
                $verifyEmailResponseDataModel->message = 'Registration Code sent successfully.';
               
            } else {
                $verifyEmailResponseDataModel->message = 'Failed to send Registration Code.';
                $verifyEmailResponseDataModel->verifyEmail=null;
            }
            
        }

    }
    function ConfirmCodeProc($confirmCodeRequestDataModel, &$confirmCodeResponseDataModel)
    {
        $confirmCode = $confirmCodeRequestDataModel->confirmCode;

        $sql1 = "CALL sp_getVerifyEmailByEmailAndCode(?,?)";
        try {

            $query1 = $this->db->query($sql1, [
                $confirmCode->email,
                $confirmCode->verificationCode,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet1 = VerifyEmailDataModel::fromDbResultSet($query1->getResultArray());
        if (empty($resultSet1)) {
            throw new VerificationCodeException(INVALID_VERIFICATION_CODE_ERROR);
        }
      
        $confirmCodeResponseDataModel->confirmCode = count($resultSet1) > 0 ? $resultSet1[0] : null;
        
    }
    

    function deleteUserProc($deleteUserRequestDataModel, &$deleteUserResponseDataModel)
    {
        $userToDelete = $deleteUserRequestDataModel->userToDelete;

        try {

            if (!empty($userToDelete->userProfileId)) {
                $sql = "CALL sp_deleteUserProfileByUserProfileId(?)";
                $query = $this->db->query($sql, [
                    $userToDelete->userProfileId
                ]);
            } else {
                $sql = "CALL sp_deleteUserProfileByEmail(?)";
                $query = $this->db->query($sql, [
                    $userToDelete->email
                ]);
            }
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet = $query->getResultArray();
        $deleteUserResponseDataModel->deletedUser = !empty($resultSet) ? $resultSet[0]['noOfRowsDeleted'] : 0;

    }

    function searchUserProc($searchUserRequestDataModel, &$searchUserResponseDataModel)
    {

        $userTypeId = $searchUserRequestDataModel->userType != null ? $searchUserRequestDataModel->userType->userTypeId : null;
        $countryId = $searchUserRequestDataModel->country != null ? $searchUserRequestDataModel->country->countryId : null;
        $stateId = $searchUserRequestDataModel->state != null ? $searchUserRequestDataModel->state->stateId : null;
        $franchiseeId = $searchUserRequestDataModel->franchisee != null ? $searchUserRequestDataModel->franchisee->franchiseeId : null;
        $roleId = $searchUserRequestDataModel->role != null ? $searchUserRequestDataModel->role->roleId : null;
        $firstName = $searchUserRequestDataModel->user != null ? $searchUserRequestDataModel->user->firstName : null;
        $middleName = $searchUserRequestDataModel->user != null ? $searchUserRequestDataModel->user->middleName : null;
        $lastName = $searchUserRequestDataModel->user != null ? $searchUserRequestDataModel->user->lastName : null;
   
        $fullName = $searchUserRequestDataModel->user != null ? $searchUserRequestDataModel->user->fullName : null;
       
        
        $email = $searchUserRequestDataModel->user != null ? $searchUserRequestDataModel->user->email : null;
       
        $statusId = $searchUserRequestDataModel->status != null ? $searchUserRequestDataModel->status->statusId : null;

        $dealerId = isset($searchUserRequestDataModel->dealer) && isset($searchUserRequestDataModel->dealer->dealerId) ? $searchUserRequestDataModel->dealer->dealerId : null;
       
        $salesExecutiveId = $searchUserRequestDataModel->salesExecutiveId != null ? $searchUserRequestDataModel->salesExecutiveId : null;
   
        $pagination = $searchUserRequestDataModel->pagination;

        $sql = "CALL sp_searchUser(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try {
            $query = $this->db->query($sql, [
                $userTypeId,
                $countryId,
                $stateId,
                $franchiseeId,
                $roleId,
                $firstName,
                $middleName,
                $lastName,
                $email,
                $statusId,
                $pagination->currentPage,
                $pagination->pageSize,
                $dealerId,
                $salesExecutiveId,
                $fullName
                
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet1 = $query->getResultArray();
      
        $searchUserResponseDataModel->users = !empty($resultSet1) ? UserProfileDataModel::fromDbResultSet($resultSet1) : null;

        // Move to the next result set
        $this->db->connID->next_result();

        // Fetch the next result set for pagination
        $nextResultSet = $this->db->connID->store_result();
        $resultSet2 = PaginationDataModel::fromDbResultSet($nextResultSet->fetch_all(MYSQLI_ASSOC));
        $searchUserResponseDataModel->pagination = count($resultSet2) > 0 ? $resultSet2[0] : null;

        // $resultSet2 = $nextResultSet->fetch_all(MYSQLI_ASSOC);
        // $searchUserResponseDataModel->pagination = !empty($resultSet2) ? PaginationDataModel::fromDbResultSet($resultSet2) : null;

    }
    function addDealerUsersProc($addDealerUserRequestDataModel,&$addDealerUserResponseDataModel)
	{
        $users = $addDealerUserRequestDataModel->users;
        $sql1 = "CALL sp_getDealerByDealerId(?)";
		$query1 = $this->db->query($sql1,array(
		$addDealerUserRequestDataModel->dealer->dealerId));
        $this->checkDBError();	


		$resultSet1 = DealerDataModel::fromDbResultSet($query1->getResultArray());
        $addDealerUserResponseDataModel->dealer = count($resultSet1) > 0 ? $resultSet1[0] : null;
		if($addDealerUserResponseDataModel->dealer == null)
		{
			throw new Cust_DatabaseException(DB_RECORD_NOT_FOUND,'dealer '.$addDealerUserRequestDataModel->dealer->dealerId.' not found');
		}

         // Move to the next result set
         $this->db->connID->next_result();

         $hasError = array();
         foreach ($users as $user) {
            try {
                $sql2 = "CALL sp_addDealeruser(?,?)";
				$query2 = $this->db->query($sql2,array(
				$addDealerUserResponseDataModel->dealer->dealerId,
				$user->userProfileId));
                // Check for DB errors (this should be done after the query)
                $this->checkDBError();
                
            } catch (\Throwable $e) {
                // Catch any exceptions and add the error message to the array
                $hasError[] = $e->getMessage();
            }
        }
        $sql3 = "CALL sp_getDealerUserByDealerId(?)";
		$query3 = $this->db->query($sql3,array(
		$addDealerUserResponseDataModel->dealer->dealerId));
			
		$this->checkDBError();

        $resultSet3 = UserProfileDataModel::fromDbResultSet($query3->getResultArray());
		$addDealerUserResponseDataModel->users = count($resultSet3) > 0 ? $resultSet3 : null;

        if(count($hasError)>0)
		{
				throw new DatabaseException(implode("\n", $hasError));
		}
    }

    function searchUnAssignedDealerUserProc($searchUnAssignedDealerUserRequestDataModel,&$searchUnAssignedDealerUserResponseDataModel)
	{
        $countryId = $searchUnAssignedDealerUserRequestDataModel->country != null ?  $searchUnAssignedDealerUserRequestDataModel->country->countryId : null;
		$stateId = $searchUnAssignedDealerUserRequestDataModel->state != null ?  $searchUnAssignedDealerUserRequestDataModel->state->stateId : null;
		$roleId = $searchUnAssignedDealerUserRequestDataModel->role != null ?  $searchUnAssignedDealerUserRequestDataModel->role->roleId : null;
		$firstName = $searchUnAssignedDealerUserRequestDataModel->user != null ?  $searchUnAssignedDealerUserRequestDataModel->user->firstName : null;
		$middleName = $searchUnAssignedDealerUserRequestDataModel->user != null ?  $searchUnAssignedDealerUserRequestDataModel->user->middleName : null;
		$lastName = $searchUnAssignedDealerUserRequestDataModel->user != null ?  $searchUnAssignedDealerUserRequestDataModel->user->lastName : null;
		$fullName = $searchUnAssignedDealerUserRequestDataModel->user != null ?  $searchUnAssignedDealerUserRequestDataModel->user->fullName : null;
		$email = $searchUnAssignedDealerUserRequestDataModel->user != null ?  $searchUnAssignedDealerUserRequestDataModel->user->email : null;
		$pagination = $searchUnAssignedDealerUserRequestDataModel->pagination;

        $sql = "CALL sp_searchUnAssignedDealerUser(?,?,?,?,?,?,?,?,?,?)";
        try {
            $query =$this->db->query($sql,array(
                $countryId,
                $stateId,
                $roleId,
                $firstName,
                $middleName,
                $lastName,
                $email,
                $pagination->currentPage,
                $pagination->pageSize,
                $fullName
            ));
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
        $this->checkDBError();

        $resultSet1 = $query->getResultArray();
        $searchUnAssignedDealerUserResponseDataModel->users = !empty($resultSet1) ? UserProfileDataModel::fromDbResultSet($resultSet1) : null;

        // Move to the next result set
        $this->db->connID->next_result();

        // Fetch the next result set for pagination
        $nextResultSet = $this->db->connID->store_result();
        $resultSet2 = PaginationDataModel::fromDbResultSet($nextResultSet->fetch_all(MYSQLI_ASSOC));
        $searchUnAssignedDealerUserResponseDataModel->pagination = count($resultSet2) > 0 ? $resultSet2[0] : null;


    }
}