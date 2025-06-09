<?php

namespace App\Models\Common\DataModels;

use CodeIgniter\Model;

class VerifyEmailDataModel extends BaseDataModel
{
    public $emailVerificationId;
    public $email;
    public $verificationCode;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        // Add validation and enrichment logic here
    }
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $verifyEmailDataModel = new VerifyEmailDataModel();
        if ($jsonData !== null) {
            $verifyEmailDataModel->emailVerificationId = $jsonData->emailVerificationId ?? null;
            $verifyEmailDataModel->email = $jsonData->email ?? null;
            $verifyEmailDataModel->verificationCode = $jsonData->verificationCode ?? null;
        }
        return $verifyEmailDataModel;
    }
    public static function fromDbResultSet($dbResultSet)
    {
        $verifyEmails = [];
        if ($dbResultSet !== null) {
            foreach ($dbResultSet as $row) {
                $verifyEmails[] = self::fromDbResultRow($row);
            }
        }
        return $verifyEmails;
    }

    public static function fromDbResultRow($row)
    {
        $verifyEmail = null;
        if ($row !== null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $verifyEmail = new VerifyEmailDataModel();
            $verifyEmail->emailVerificationId = $objRow->emailVerificationId ?? null;
            $verifyEmail->email = $objRow->email ?? null;
            $verifyEmail->verificationCode = $objRow->verificationCode ?? null;
        }
        return $verifyEmail;
    }

}