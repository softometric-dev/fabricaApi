<?php

namespace App\Config;

use CodeIgniter\Config\BaseConfig;

class JWT extends BaseConfig
{
    // JWT Keys
    public $idTokenKey = 'd0pdrfa&n*S3qy7$ouklw$vN8UA$+!FmC=aa93aT!=@W+Jcl';
    public $accessTokenKey = 'Q^)lq9iTD2RlOxnai^^6elDANpUz30MmRoP9nf!$QRHU5333';
    public $refreshTokenKey = '4c8P4IsRyGRANIV1+l9H@A9cHqZ)ZWmM_F1mLBQ(BGHWhb8!';

    // JWT Algorithm Types
    public $idTokenAlgorithm = 'HS256';
    public $accessTokenAlgorithm = 'HS256';
    public $refreshTokenAlgorithm = 'HS256';

    // Token Request Header Name
    public $tokenHeader = 'Authorization';

    // Token Expire Times (in seconds)
    public $idTokenExpireTime = 14400; // 4 Hours
    // public $accessTokenExpireTime = 3600; // 1 Hour
    public $accessTokenExpireTime = 28800; // 8 Hours
    // public $accessTokenExpireTime = 180;
    public $refreshTokenExpireTime = 14400; // 4 Hours

    // Token Parameters
    public const AUTH_TOKEN_PAYLOAD = 'payload';
    public const AUTH_TOKEN_ISSUER = 'stroomx.com';
    public const AUTH_TOKEN_AUDIENCE_FMS = 'FMS';
}
