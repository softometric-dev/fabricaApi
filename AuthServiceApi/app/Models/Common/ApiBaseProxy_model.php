<?php

namespace App\Models\Common;

use CodeIgniter\Model;
use App\Libraries\{
    ApiCallException,CustomException,
};
use App\Models\Common\DataModels\BaseDataModel;

class ApiBaseProxy_model extends Model
{
    // Properties
    private $baseUrl;

    // Constructor
    public function __construct($baseUrl)
    {
        parent::__construct();
        $this->baseUrl = $baseUrl;
    }

    protected function invokeApi($route, $requestJsonData)
    {
        $request = \Config\Services::request();
        $authorizationToken = $request->getHeaderLine('Authorization');
        $url = $this->baseUrl . $route;

        $client = curl_init($url);
        curl_setopt($client, CURLOPT_POST, true);
        curl_setopt($client, CURLOPT_POSTFIELDS, $requestJsonData);
        curl_setopt($client, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($client, CURLOPT_HTTPHEADER, [
            'Authorization: ' . $authorizationToken,
            'Content-Type: application/json'
        ]);

        $response = curl_exec($client);
        $httpStatus = curl_getinfo($client, CURLINFO_HTTP_CODE);
        $error = curl_error($client);
        curl_close($client);

        if ($response === false) {
            $message = 'Api invoke failed. ' . $error;
            throw new ApiCallException($message);
        }

        $responseJsonData = BaseDataModel::jsonDecode($response);

        if ($responseJsonData === null || $httpStatus != 200) {
            $message = 'Api invoke failed. httpStatus: ' . $httpStatus;
            throw new ApiCallException($message, $httpStatus, $responseJsonData);
        }

        return $responseJsonData;
    }
}
