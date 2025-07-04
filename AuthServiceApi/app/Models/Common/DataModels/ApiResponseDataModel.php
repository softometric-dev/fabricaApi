<?php

namespace App\Models\Common\DataModels;

use App\Libraries\CustomException;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ErrorDetailsDataModel;

class ApiResponseDataModel extends BaseDataModel
{
    public $apiUrl;
    public $action;
    public $success;
    public $errorCode;
    public $message;
    public $trace;
    public $additionalErrorDetails;

    public function __construct()
    {
        parent::__construct();
        $this->apiUrl = current_url();
        $this->action = uri_string();
        $this->additionalErrorDetails = [];
    }

    public function setErrorDetails($exception)
    {
        $this->errorCode = $exception instanceof CustomException ? $exception->getErrorCode() : GENERIC_ERROR;
        $this->message = $exception->getMessage();
        $this->trace = $exception->getTraceAsString();
    }

    public function setAdditionalErrorDetails($exception)
    {
        $this->additionalErrorDetails = $exception;
    }

    public function toJson()
    {
        return json_encode(get_object_vars($this));
    }

    public static function fromJson($jsonString)
    {
        // $jsonData = json_decode($jsonString, true);

        // if (json_last_error() !== JSON_ERROR_NONE) {
        //     throw new \Exception('Invalid JSON string');
        // }

        // $instance = new self();
        // $instance->apiUrl = $jsonData['apiUrl'] ?? null;
        // $instance->action = $jsonData['action'] ?? null;
        // $instance->success = $jsonData['success'] ?? null;
        // $instance->errorCode = $jsonData['errorCode'] ?? null;
        // $instance->message = $jsonData['message'] ?? null;
        // $instance->trace = $jsonData['trace'] ?? null;
        // $instance->additionalErrorDetails = $jsonData['additionalErrorDetails'] ?? [];

        // return $instance;
    }

    public function validateAndEnrichData()
    {
        // Implement validation and enrichment logic
    }
}
