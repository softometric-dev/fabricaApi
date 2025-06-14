<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\ProductEnquiryDataModel;
use App\Libraries\{ParameterException};

class SearchProductEnquiryRequestDataModel extends PaginationRequestDataModel
{

    public $productEnquiry;
    public $pagination;

    public function __construct()
    {
        parent::__construct();
    }
    public function validateAndEnrichData()
    {
        $productEnquiry = $this->productEnquiry;
        $pagination = $this->pagination;

        // Validate mandatory inputs
        if (
            (
                empty($productEnquiry)
            ) &&
            empty($pagination) ||
            empty($pagination->currentPage) ||
            empty($pagination->pageSize)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'productEnquiry, currentPage, pageSize');
        }

        // Optional inputs and setting defaults
        // Add additional defaults here if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $searchProductEnquiryRequestDataModel = new SearchProductEnquiryRequestDataModel();

        if ($jsonData !== null) {

            $productEnquiry = $jsonData->productEnquiry ?? null;
            if ($productEnquiry !== null) {
                $searchProductEnquiryRequestDataModel->productEnquiry = ProductEnquiryDataModel::fromJson($productEnquiry);
            }


            $pagination = $jsonData->pagination ?? null;
            if ($pagination !== null) {
                $searchProductEnquiryRequestDataModel->pagination = PaginationDataModel::fromJson($pagination);
            }
        }

        return $searchProductEnquiryRequestDataModel;
    }
}