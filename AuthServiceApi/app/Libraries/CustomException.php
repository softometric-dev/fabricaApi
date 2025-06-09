<?php
// File: app/Exceptions/CustomException.php
namespace App\Libraries;

use Throwable;

class CustomException extends \Exception
{
    protected $errorCode;
    protected $httpStatus;
    protected $CI;

    public function __construct($error, $additionalErrorDetails = '', $httpStatus = 500, Throwable $previous = null)
    {
        // $this->CI = &get_instance();
        // $message = $this->CI->lang->line($error);
        // $message = lang($error);
        $message = lang('error_messages_lang.' . $error);
   
       
        if (empty($message)) {
            $this->errorCode = GENERIC_ERROR;
            $message = $error . '.' . $additionalErrorDetails;
        } else {
            $this->errorCode = $error;
            $message = $message . $additionalErrorDetails;
        }

        $this->httpStatus = $httpStatus;
        parent::__construct($message, $httpStatus, $previous);
    }

    public function getHttpStatusCode()
    {
        return $this->httpStatus;
    }

    public function getErrorCode()
    {
        return $this->errorCode;
    }

    public static function exceptionHandler($severity, $message, $file, $line)
    {
        // You might choose to log this error before throwing an exception
        throw new self($message, '', $severity);
    }
}

class ParameterException extends CustomException
{
    public static function exceptionHandler($severity, $message, $file, $line)
    {
        throw new self($message, '', $severity);
    }
}

class JsonException extends CustomException
{
    public static function exceptionHandler($severity, $message, $file, $line)
    {
        throw new self($message, '', $severity);
    }
}

class FileSystemException extends CustomException
{
    public static function exceptionHandler($severity, $message, $file, $line)
    {
        throw new self($message, '', $severity);
    }
}

class DatabaseException extends CustomException
{
    public static function exceptionHandler($severity, $message, $file, $line)
    {
        throw new self($message, '', $severity);
    }
}

class AuthenticationException extends CustomException
{
   
    public function __construct($error, $additionalErrorDetails = '', Throwable $previous = null)
    {
        parent::__construct($error, $additionalErrorDetails, 401, $previous);
    }

    public static function exceptionHandler($severity, $message, $file, $line)
    {
       
        // throw new self($message, '', $severity);
        // throw new DatabaseException($message, $severity);
        throw new AuthenticationException($message, $severity);
    }
}

class AuthorisationException extends CustomException
{
    public function __construct($error, $additionalErrorDetails = '', Throwable $previous = null)
    {
        parent::__construct($error, $additionalErrorDetails, 403, $previous);
    }

    public static function exceptionHandler($severity, $message, $file, $line)
    {
        throw new self($message, '', $severity);
    }
}

class ApiCallException extends CustomException
{
    private $apiException;

    public function __construct($message = "", $httpStatus = 500, $apiException = null)
    {
        $apiErrorMessage = $apiException != null && isset($apiException->message) ? $apiException->message : '';
        parent::__construct($message, $apiErrorMessage, $httpStatus);
        $this->errorCode = $apiException != null && isset($apiException->errorCode) ? $apiException->errorCode : $this->errorCode;
        $this->apiException = $apiException;
    }

    public function getApiException()
    {
        return $this->apiException;
    }

    public static function exceptionHandler($severity, $message, $file, $line)
    {
        throw new self($message, '', $severity);
    }
}
