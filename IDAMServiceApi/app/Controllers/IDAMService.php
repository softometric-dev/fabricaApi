<?php

namespace App\Controllers;
use CodeIgniter\Controller;
use App\Libraries\{ApiCallException, AuthorisationException, CustomException, DatabaseException};
use App\Models\IDAMService_model;
use App\Controllers\BaseController;
use App\Models\DataModels\Requests\CreateUserRequestDataModel;
use App\Models\DataModels\Responses\CreateUserResponseDataModel;
use App\Models\DataModels\Requests\GetUserRequestDataModel;
use App\Models\DataModels\Responses\GetUserResponseDataModel;
use App\Models\DataModels\Requests\DeleteUserRequestDataModel;
use App\Models\DataModels\Responses\DeleteUserResponseDataModel;
use App\Models\DataModels\Requests\CreateRoleRequestDataModel;
use App\Models\DataModels\Responses\CreateRoleResponseDataModel;
use App\Models\DataModels\Requests\GetRoleRequestDataModel;
use App\Models\DataModels\Responses\GetRoleResponseDataModel;
use App\Models\DataModels\Requests\DeleteRoleRequestDataModel;
use App\Models\DataModels\Responses\DeleteRoleResponseDataModel;
use App\Models\DataModels\Requests\CreatePermissionRequestDataModel;
use App\Models\DataModels\Responses\CreatePermissionResponseDataModel;
use App\Models\DataModels\Requests\GetPermissionRequestDataModel;
use App\Models\DataModels\Responses\GetPermissionResponseDataModel;
use App\Models\DataModels\Requests\DeletePermissionRequestDataModel;
use App\Models\DataModels\Responses\DeletePermissionResponseDataModel;
use App\Models\DataModels\Requests\AddRolePermissionsRequestDataModel;
use App\Models\DataModels\Responses\AddRolePermissionsResponseDataModel;
use App\Models\DataModels\Requests\GetRolePermissionsRequestDataModel;
use App\Models\DataModels\Responses\GetRolePermissionsResponseDataModel;
use App\Models\DataModels\Requests\AddUserRolesRequestDataModel;
use App\Models\DataModels\Responses\AddUserRolesResponseDataModel;
use App\Models\DataModels\Requests\GetUserRolesRequestDataModel;
use App\Models\DataModels\Responses\GetUserRolesResponseDataModel;
use App\Models\DataModels\Requests\GetUserPermissionsRequestDataModel;
use App\Models\DataModels\Responses\GetUserPermissionsResponseDataModel;
use App\Models\DataModels\Requests\GetAllUserTypesRequestDataModel;
use App\Models\DataModels\Responses\GetAllUserTypesResponseDataModel;
use App\Models\DataModels\Requests\SearchUserRequestDataModel;
use App\Models\DataModels\Responses\SearchUserResponseDataModel;
use App\Models\DataModels\Requests\SearchUnAssignedFranchiseeUserRequestDataModel;
use App\Models\DataModels\Responses\SearchUnAssignedFranchiseeUserResponseDataModel;
use App\Models\DataModels\Requests\GetAllStatusRequestDataModel;
use App\Models\DataModels\Responses\GetAllStatusResponseDataModel;
use App\Models\DataModels\Requests\GetAllUserRolesRequestDataModel;
use App\Models\DataModels\Responses\GetAllUserRolesResponseDataModel;
use App\Models\DataModels\Requests\AddFranchiseeUserRequestDataModel;
use App\Models\DataModels\Responses\AddFranchiseeUserResponseDataModel;
use App\Models\DataModels\Requests\SearchRoleRequestDataModel;
use App\Models\DataModels\Responses\SearchRoleResponseDataModel;
use App\Models\DataModels\Requests\CreateRoleAndAddPermissionRequestDataModel;
use App\Models\DataModels\Responses\CreateRoleAndAddPermissionResponseDataModel;
use App\Models\DataModels\Requests\GetUserStatiticsRequestDataModel;
use App\Models\DataModels\Responses\GetUserStatiticsResponseDataModel;
use App\Models\DataModels\Requests\SearchPermissionRequestDataModel;
use App\Models\DataModels\Responses\SearchPermissionResponseDataModel;
use App\Models\DataModels\Requests\SearchUserAuditLogRequestDataModel;
use App\Models\DataModels\Responses\SearchUserAuditLogResponseDataModel;
use App\Models\DataModels\Requests\UpdateUserRequestDataModel;
use App\Models\DataModels\Responses\UpdateUserResponseDataModel;
use App\Models\DataModels\Requests\UpdateRoleRequestDataModel;
use App\Models\DataModels\Responses\UpdateRoleResponseDataModel;
use App\Models\DataModels\Requests\ForgotPasswordRequestDataModel;
use App\Models\DataModels\Responses\ForgotPasswordResponseDatamodel;
use App\Models\DataModels\Requests\AddDealerUserRequestDataModel;
use App\Models\DataModels\Responses\AddDealerUserResponseDataModel;
use App\Models\DataModels\Requests\SearchUnAssignedDealerUserRequestDataModel;
use App\Models\DataModels\Responses\SearchUnAssignedDealerUserResponseDataModel;
use App\Models\DataModels\Requests\VerifyEmailRequestDataModel;
use App\Models\DataModels\Responses\VerifyEmailResponseDataModel;
use App\Models\DataModels\Requests\ConfirmCodeRequestDataModel;
use App\Models\DataModels\Responses\ConfirmCodeResponseDataModel;

use CodeIgniter\Email\Email;
class IDAMService extends BaseController
{
    protected $IDAMService_model;
    protected $emailService;

    public function __construct()
    {
        $this->IDAMService_model = new IDAMService_model();
        $this->emailService = service('email'); // Assuming you use the Email service
    }



    public function createUser()
    {
        try {
            // Set custom error handler
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $createUserResponseDataModel = new CreateUserResponseDataModel();

            // Authenticate user permissions
            // $authInfo = $this->checkPermission(); // Define this method or use appropriate authentication

            // Load request data
            $createUserRequestDataModel = CreateUserRequestDataModel::fromJson($this->request->getBody());
            // $createUserRequestDataModel->authInfo = $authInfo;
            $createUserRequestDataModel->validateAndEnrichData();

            // Set database error handler
            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->createUserProc($createUserRequestDataModel,$createUserResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            // Send success response
            $this->sendSuccessResponse($createUserResponseDataModel);


        } catch (\Exception $e) {
            
            $createUserResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($createUserResponseDataModel, $e);

        }
    }

    public function registerUser()
    {
        try {
            // Set custom error handler
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $registerUserResponseDataModel = new CreateUserResponseDataModel();

            // Authenticate user permissions
            // $authInfo = $this->checkPermission(); // Define this method or use appropriate authentication

            // Load request data
            $registerUserRequestDataModel = CreateUserRequestDataModel::fromJson($this->request->getBody());
            // $createUserRequestDataModel->authInfo = $authInfo;
            $registerUserRequestDataModel->validateAndEnrichData();

            // Set database error handler
            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->registerUserProc($registerUserRequestDataModel,$registerUserResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            // Send success response
            $this->sendSuccessResponse($registerUserResponseDataModel);


        } catch (\Exception $e) {

            $registerUserResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($registerUserResponseDataModel, $e);
        }
    }


    private function sendUserCreationEmail($userEmail, $password, $userProfileId)
    {
        // Configure the email
        $this->emailService->setFrom('munshiramuni1996@gmail.com', 'Softometric');
        $this->emailService->setTo($userEmail);
        $this->emailService->setSubject('Account Created Successfully');

        $passwordResetLink = "http://localhost/ecoomerce/reset_password_view/" . base64_encode($userProfileId);

        $message = 'Your account has been successfully created. Your username is: ' . $userEmail . '<br>';
        $message .= 'Your password is: ' . $password . '<br>';
        $message .= 'For security reasons, we recommend you reset your password immediately after logging in. ';
        $message .= 'Please <a href="' . $passwordResetLink . '">click here</a> to reset your password.';

        $this->emailService->setMessage($message);

        // Send the email
        if (!$this->emailService->send()) {
            // Handle error
            log_message('error', 'Email failed to send: ' . $this->emailService->printDebugger());
        }
    }

    public function UpdateUser()
    {
        try {
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $updateUserResponseDataModel = new UpdateUserResponseDataModel();

            // $authInfo = $this->checkPermission();

            $updateUserRequestDataModel = UpdateUserRequestDataModel::fromJson($this->request->getBody());
            // $updateUserRequestDataModel->authInfo = $authInfo;
            $updateUserRequestDataModel->validateAndEnrichData();

            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->updateUserProc($updateUserRequestDataModel, $updateUserResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($updateUserResponseDataModel);
        } catch (\Exception $e) {

            $updateUserResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($updateUserResponseDataModel, $e);
        }
    }

    public function getUser()
    {
        try {
            // Set custom error handler
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $getUserResponseDataModel = new GetUserResponseDataModel();

            // $authInfo = $this->checkPermission();

            $getUserRequestDataModel = GetUserRequestDataModel::fromJson($this->request->getBody());
            // $getUserRequestDataModel->authInfo = $authInfo;
            $getUserRequestDataModel->validateAndEnrichData();

            // Set database error handler
            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->getUserProc($getUserRequestDataModel, $getUserResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($getUserResponseDataModel);
        } catch (\Exception $e) {
            $getUserResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($getUserResponseDataModel, $e);
        }
    }

    public function deleteUser()
    {
        try {
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $deleteUserResponseDataModel = new DeleteUserResponseDataModel();

            // $authInfo = $this->checkPermission();

            $deleteUserRequestDataModel = DeleteUserRequestDataModel::fromJson($this->request->getBody());
            // $deleteUserRequestDataModel->authInfo = $authInfo;
            $deleteUserRequestDataModel->validateAndEnrichData();

            // Set database error handler
            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->deleteUserProc($deleteUserRequestDataModel, $deleteUserResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($deleteUserResponseDataModel);
        } catch (\Exception $e) {
            $deleteUserResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($deleteUserResponseDataModel, $e);
        }
    }

    public function forgotPassword()
    {
        try {


            set_error_handler([CustomException::class, 'exceptionHandler']);
            $forgotPasswordResponseDatamodel = new ForgotPasswordResponseDatamodel();

            // $authInfo = $this->checkPermission();

            $forgotPasswordRequestDataModel = ForgotPasswordRequestDataModel::fromJson($this->request->getBody());
            // $deleteUserRequestDataModel->authInfo = $authInfo;
            $forgotPasswordRequestDataModel->validateAndEnrichData();

            // Set database error handler
            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->forgotPasswordProc($forgotPasswordRequestDataModel, $forgotPasswordResponseDatamodel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($forgotPasswordResponseDatamodel);
        } catch (\Exception $e) {
            $forgotPasswordResponseDatamodel->setErrorDetails($e);
            $this->sendErrorResponse($forgotPasswordResponseDatamodel, $e);
        }
    }

    public function searchUser()
    {
        try {

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $searchUserResponseDataModel = new SearchUserResponseDataModel();

            // $authInfo = $this->checkPermission();

            $searchUserRequestDataModel = SearchUserRequestDataModel::fromJson($this->request->getBody());
            // $searchUserRequestDataModel->authInfo = $authInfo;
            $searchUserRequestDataModel->validateAndEnrichData();

            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->searchUserProc($searchUserRequestDataModel, $searchUserResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($searchUserResponseDataModel);
        } catch (\Exception $e) {
            $searchUserResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($searchUserResponseDataModel, $e);
        }
    }

    public function addDealerUsers()
    {
        try {

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $addDealerUserResponseDataModel = new AddDealerUserResponseDataModel();

            // $authInfo = $this->checkPermission();

            $addDealerUserRequestDataModel = AddDealerUserRequestDataModel::fromJson($this->request->getBody());
            // $searchUserRequestDataModel->authInfo = $authInfo;
            $addDealerUserRequestDataModel->validateAndEnrichData();

            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->addDealerUsersProc($addDealerUserRequestDataModel, $addDealerUserResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($addDealerUserResponseDataModel);
        } catch (\Exception $e) {
            $addDealerUserResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($addDealerUserResponseDataModel, $e);
        }
    }

    public function searchUnAssignedDealerUser()
    {
        try {

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $searchUnAssignedDealerUserResponseDataModel = new SearchUnAssignedDealerUserResponseDataModel();

            // $authInfo = $this->checkPermission();

            $searchUnAssignedDealerUserRequestDataModel = SearchUnAssignedDealerUserRequestDataModel::fromJson($this->request->getBody());
            // $searchUserRequestDataModel->authInfo = $authInfo;
            $searchUnAssignedDealerUserRequestDataModel->validateAndEnrichData();

            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->searchUnAssignedDealerUserProc($searchUnAssignedDealerUserRequestDataModel, $searchUnAssignedDealerUserResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($searchUnAssignedDealerUserResponseDataModel);
        } catch (\Exception $e) {
            $searchUnAssignedDealerUserResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($searchUnAssignedDealerUserResponseDataModel, $e);
        }
    }

    public function verifyEmail()
    {
        try {


            set_error_handler([CustomException::class, 'exceptionHandler']);
            $verifyEmailResponseDataModel = new VerifyEmailResponseDataModel();

            // $authInfo = $this->checkPermission();

            $verifyEmailRequestDataModel = VerifyEmailRequestDataModel::fromJson($this->request->getBody());
            // $searchUserRequestDataModel->authInfo = $authInfo;
            $verifyEmailRequestDataModel->validateAndEnrichData();

            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->verifyEmailProc($verifyEmailRequestDataModel, $verifyEmailResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($verifyEmailResponseDataModel);
        } catch (\Exception $e) {
            $verifyEmailResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($verifyEmailResponseDataModel, $e);
        }
    }

    public function confirmCode()
    {
        try {


            set_error_handler([CustomException::class, 'exceptionHandler']);
            $confirmCodeResponseDataModel = new ConfirmCodeResponseDataModel();

            // $authInfo = $this->checkPermission();

            $confirmCodeRequestDataModel = ConfirmCodeRequestDataModel::fromJson($this->request->getBody());
            // $searchUserRequestDataModel->authInfo = $authInfo;
            $confirmCodeRequestDataModel->validateAndEnrichData();
	
            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->IDAMService_model->ConfirmCodeProc($confirmCodeRequestDataModel, $confirmCodeResponseDataModel);
            set_error_handler([CustomException::class, 'exceptionHandler']);

            $this->sendSuccessResponse($confirmCodeResponseDataModel);
        } catch (\Exception $e) {
           
            $confirmCodeResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($confirmCodeResponseDataModel, $e);
            
        }
    }
}