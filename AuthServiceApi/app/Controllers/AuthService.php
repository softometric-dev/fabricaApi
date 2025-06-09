<?php

namespace App\Controllers;

use App\Libraries\{
    AuthenticationException,
    CustomException,
    DatabaseException,
    AuthToken
};
use App\Models\{
    AuthService_model,
    DataModels\Requests\LoginRequestDataModel,
    DataModels\Responses\LoginResponseDataModel,
    DataModels\Requests\LogoffRequestDataModel,
    DataModels\Responses\LogoffResponseDataModel,
    DataModels\Requests\RefreshTokenRequestDataModel,
    DataModels\Responses\RefreshTokenResponseDataModel,
    DataModels\Requests\HasPermissionRequestDataModel,
    DataModels\Responses\HasPermissionResponseDataModel,
    DataModels\Requests\ImpersonateUserRequestDataModel,
    DataModels\Responses\ImpersonateUserResponseDataModel
};

use CodeIgniter\API\ResponseTrait;

class AuthService extends BaseController
{
    use ResponseTrait;

    protected $authServiceModel;

    public function __construct()
    {
        parent::__construct();
        $this->authServiceModel = new AuthService_model();
        helper('common'); // Load helper in CI4
        $this->authToken = new AuthToken();  // Assuming auth_token is registered as a service
    }

    public function login()
    {
        try {
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $loginResponseDataModel = new LoginResponseDataModel();

            $this->authToken->validateToken();

            $loginRequestDataModel = LoginRequestDataModel::fromJson($this->request->getBody());
            $loginRequestDataModel->authInfo = $this->authToken->authInfo;
            $loginRequestDataModel->validateAndEnrichData();

            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $payload = $this->authServiceModel->loginProc($loginRequestDataModel);

            $loginResponseDataModel->token = $this->authToken->generateToken($payload);
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($loginResponseDataModel);
           
        } catch (\Exception $e) {
         
            $loginResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($loginResponseDataModel, $e);

        }
    }

    public function impersonateUser()
    {
        try {
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $impersonateUserResponseDataModel = new ImpersonateUserResponseDataModel();

            $this->authToken->validateToken();
            $this->checkPermission();

            $impersonateUserRequestDataModel = ImpersonateUserRequestDataModel::fromJson($this->request->getBody());
            $impersonateUserRequestDataModel->authInfo = $this->authToken->authInfo;
            $impersonateUserRequestDataModel->validateAndEnrichData();

            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $payload = $this->authServiceModel->impersonateUserProc($impersonateUserRequestDataModel);

            $impersonateUserResponseDataModel->token = $this->authToken->generateToken($payload);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($impersonateUserResponseDataModel);

        } catch (\Exception $e) {
            $impersonateUserResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($impersonateUserResponseDataModel, $e);

        }
    }

    public function logoff()
    {
        try {
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $logoffResponseDataModel = new LogoffResponseDataModel();

            $this->authToken->validateToken();

            $logoffRequestDataModel = LogoffRequestDataModel::fromJson($this->request->getBody());
            $logoffRequestDataModel->authInfo = $this->authToken->authInfo;
            $logoffRequestDataModel->validateAndEnrichData();

            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->authServiceModel->logoffProc($logoffRequestDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($logoffResponseDataModel);

        } catch (\Exception $e) {
            $logoffResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($logoffResponseDataModel, $e);

        }
    }

    public function refreshToken()
    {
        try {
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $refreshTokenResponseDataModel = new RefreshTokenResponseDataModel();

           
            $this->authToken->validateToken();
           
           
            $refreshTokenRequestDataModel = RefreshTokenRequestDataModel::fromJson($this->request->getBody());
            // $refreshTokenRequestDataModel->validateAndEnrichData();

            
            set_error_handler([DatabaseException::class, 'exceptionHandler']);
         
            $payload = $this->authServiceModel->refreshTokenProc($refreshTokenRequestDataModel);
            $refreshTokenResponseDataModel->token = $this->authToken->generateToken($payload);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($refreshTokenResponseDataModel);

        } catch (\Exception $e) {
            $refreshTokenResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($refreshTokenResponseDataModel, $e);

        }
    }

    public function hasPermission()
    {
        try {


            set_error_handler([CustomException::class, 'exceptionHandler']);
            $hasPermissionResponseDataModel = new HasPermissionResponseDataModel();

            $this->authToken->validateToken();


            $hasPermissionRequestDataModel = HasPermissionRequestDataModel::fromJson($this->request->getBody());
            $hasPermissionRequestDataModel->authInfo = $this->authToken->authInfo;
            $hasPermissionRequestDataModel->validateAndEnrichData();

            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->authServiceModel->hasPermissionProc($hasPermissionRequestDataModel, $hasPermissionResponseDataModel);
            $hasPermissionResponseDataModel->authInfo = $this->authToken->authInfo;

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($hasPermissionResponseDataModel);

        } catch (\Exception $e) {

            $hasPermissionResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($hasPermissionResponseDataModel, $e);

        }
    }
}
