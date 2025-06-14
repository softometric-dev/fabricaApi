<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\ProductEnquiryDataModel;
use App\Libraries\{ParameterException};

class DeleteProductEnquiryRequestDataModel extends ApiRequestDataModel
{

    public $productEnquiryToDelete;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $productEnquiryToDelete = $this->productEnquiryToDelete;

        // Validate mandatory inputs
        if (empty($productEnquiryToDelete) || empty($productEnquiryToDelete->productEnquiryId)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'productEnquiryId');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $deleteProductEnquiryRequestDataModel = new DeleteProductEnquiryRequestDataModel();

        if ($jsonData !== null) {
            $productEnquiryToDelete = $jsonData->productEnquiryToDelete ?? null;
            if ($productEnquiryToDelete !== null) {
                $productEnquiryDataModel = ProductEnquiryDataModel::fromJson($productEnquiryToDelete);
                $deleteProductEnquiryRequestDataModel->productEnquiryToDelete = $productEnquiryDataModel;
            }
        }

        return $deleteProductEnquiryRequestDataModel;
    }

}