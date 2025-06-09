<?php

namespace App\Libraries;

use App\Libraries\{
    AuthenticationException,
    CustomException,
    DatabaseException,
   
};
use Config\Services;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use App\Config\JWT as JWTConfig;
use App\Models\Common\DataModels\AuthTokenDataModel;
use App\Models\Common\DataModels\IdTokenPayloadDataModel;
use App\Models\Common\DataModels\AccessTokenPayloadDataModel;
use App\Models\Common\DataModels\AuthInfoDataModel;

class AuthToken
{
    protected $idTokenKey;
    protected $accessTokenKey;
    protected $refreshTokenKey;
    protected $idTokenAlgorithm;
    protected $accessTokenAlgorithm;
    protected $refreshTokenAlgorithm;
    protected $header;
    protected $idTokenExpireTime; 
    protected $accessTokenExpireTime; 
    protected $refreshTokenExpireTime; 
    public $authInfo;

    public function __construct()
    {
        $config = new JWTConfig(); // Load JWT configuration
        $this->idTokenKey = $config->idTokenKey;
        $this->idTokenAlgorithm = $config->idTokenAlgorithm;
        $this->idTokenExpireTime = $config->idTokenExpireTime;
        $this->accessTokenKey = $config->accessTokenKey;
        $this->accessTokenAlgorithm = $config->accessTokenAlgorithm;
        $this->accessTokenExpireTime = $config->accessTokenExpireTime;
        $this->refreshTokenKey = $config->refreshTokenKey;
        $this->refreshTokenAlgorithm = $config->refreshTokenAlgorithm;
        $this->refreshTokenExpireTime = $config->refreshTokenExpireTime;
        $this->header = $config->tokenHeader;
        $this->authInfo = null;
    }

    public function generateToken($userProfile = null)
    {
        $authToken = new AuthTokenDataModel();
        if ($userProfile && is_object($userProfile)) {
            $apiTime = time();
            $authToken->idToken = $this->generateIdToken($userProfile, $apiTime);
            $authToken->accessToken = $this->generateAccessToken($userProfile, $apiTime);
            $authToken->refreshToken = $this->generateRefreshToken($userProfile, $apiTime);
        } else {
            throw new Exception("token payload is null");
        }

        return $authToken;
    }

    private function generateIdToken($userProfile, $apiTime)
    {
        $idTokenPayload = new IdTokenPayloadDataModel();
        $idTokenPayload->iss = JWTConfig::AUTH_TOKEN_ISSUER;
        $idTokenPayload->aud = JWTConfig::AUTH_TOKEN_AUDIENCE_FMS;
        $idTokenPayload->iat = $apiTime;
        $idTokenPayload->exp = $idTokenPayload->iat + $this->idTokenExpireTime;
        $idTokenPayload->sub = $userProfile->userProfileId;
        $idTokenPayload->userProfileId = $userProfile->userProfileId;
        $idTokenPayload->userType = $userProfile->userType;
        $idTokenPayload->email = $userProfile->email;
        $idTokenPayload->firstName = $userProfile->firstName;
        $idTokenPayload->middleName = $userProfile->middleName;
        $idTokenPayload->lastName = $userProfile->lastName;
        return JWT::encode([JWTConfig::AUTH_TOKEN_PAYLOAD => $idTokenPayload], $this->idTokenKey, $this->idTokenAlgorithm);
    }

    private function generateAccessToken($userProfile, $apiTime)
    {
        $accessTokenPayload = new AccessTokenPayloadDataModel();
        $accessTokenPayload->iss = JWTConfig::AUTH_TOKEN_ISSUER;
        $accessTokenPayload->aud = JWTConfig::AUTH_TOKEN_AUDIENCE_FMS;
        $accessTokenPayload->iat = $apiTime;
        $accessTokenPayload->exp = $accessTokenPayload->iat + $this->accessTokenExpireTime;
        $accessTokenPayload->sub = $userProfile->userProfileId.','.$userProfile->userType->userType;
        return JWT::encode([JWTConfig::AUTH_TOKEN_PAYLOAD => $accessTokenPayload], $this->accessTokenKey, $this->accessTokenAlgorithm);
    }

    private function generateRefreshToken($userProfile, $apiTime)
    {
        $refreshTokenPayload = new AccessTokenPayloadDataModel();
        $refreshTokenPayload->iss = JWTConfig::AUTH_TOKEN_ISSUER;
        $refreshTokenPayload->aud = JWTConfig::AUTH_TOKEN_AUDIENCE_FMS;
        $refreshTokenPayload->iat = $apiTime;
        $refreshTokenPayload->exp = $refreshTokenPayload->iat + $this->refreshTokenExpireTime;
        $refreshTokenPayload->sub = $userProfile->userProfileId.','.$userProfile->userType->userType;
        return JWT::encode([JWTConfig::AUTH_TOKEN_PAYLOAD => $refreshTokenPayload], $this->refreshTokenKey, $this->refreshTokenAlgorithm);
    }

    public function validateToken()
    {
        try {
        
           
            $this->authInfo = new AuthInfoDataModel();
            $this->authInfo->remoteAddress = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['HTTP_CLIENT_IP'] ?? $_SERVER['REMOTE_ADDR'];
            $fullPath = service('router')->controllerName() . '/' . service('router')->methodName();
            $currentRoute = str_replace('\App\Controllers\\', '', $fullPath);
         
            if($currentRoute !== 'AuthService/login') {
                
             
               
                $headers = service('request')->getHeaders();
                $tokenData = $this->isTokenExist($headers);
               
                if($tokenData['status'] !== true) {
                    throw new AuthenticationException(AUTH_HEADER_NOT_FOUND_ERROR);
                }
                if(empty($tokenData['token'])) {
                    throw new AuthenticationException(EMPTY_TOKEN_ERROR);
                }

            
                $key = $this->accessTokenKey;
                $algorithm = $this->accessTokenAlgorithm;
                $expireTime = $this->accessTokenExpireTime;
                if($currentRoute === 'AuthService/refreshToken') {
                    $key = $this->refreshTokenKey;
                    $algorithm = $this->refreshTokenAlgorithm;
                    $expireTime = $this->refreshTokenExpireTime;
                }
              
  

                $decodedToken = JWT::decode($tokenData['token'], new Key($key, $algorithm));
             
  
                if(empty($decodedToken) || !is_object($decodedToken)) {
                    throw new AuthenticationException(TOKEN_FORBIDDEN_ERROR);
                }
                $this->authInfo->payload = $decodedToken->payload;
                
                if (empty($decodedToken->payload->exp) || !is_numeric($decodedToken->payload->exp)) {
                    throw new AuthenticationException(TOEKN_EXPIRY_NOT_DEFINED_ERROR);
                }

                if(strtotime('now') >= $decodedToken->payload->exp) {
                    throw new AuthenticationException(TOKEN_EXPIRED);
                }
               
            }
          
        } catch (\Exception $e) {
            throw new AuthenticationException(TOKEN_VALIDATION_ERROR, $e->getMessage());
        }
    }

    private function isTokenExist($headers)
    {
        
        if(!empty($headers) && is_array($headers)) {
            foreach ($headers as $headerName => $headerValue) {
                if (strtolower(trim($headerName)) == strtolower(trim($this->header))) {
                  
                   // Check if $headerValue is an object and get the value
                if (is_object($headerValue) && method_exists($headerValue, 'getValue')) {
                    return ['status' => true, 'token' => $headerValue->getValue()];
                } else {
                    return ['status' => true, 'token' => $headerValue];
                }
                }
            }
        }
        return ['status' => false, 'token' => null];
    }
}
