<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\DealEnquiryDataModel;
use App\Libraries\{ParameterException};

class SearchDealEnquiryRequestDataModel extends PaginationRequestDataModel
{

    public $dealEnquiry;
    public $pagination;

    public function __construct()
    {
        parent::__construct();
    }
    public function validateAndEnrichData()
    {
        $dealEnquiry = $this->dealEnquiry;
        $pagination = $this->pagination;

        // Validate mandatory inputs
        if (
            (
                empty($dealEnquiry)
            ) &&
            empty($pagination) ||
            empty($pagination->currentPage) ||
            empty($pagination->pageSize)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'dealEnquiry, currentPage, pageSize');
        }

        // Optional inputs and setting defaults
        // Add additional defaults here if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $searchDealEnquiryRequestDataModel = new SearchDealEnquiryRequestDataModel();

        if ($jsonData !== null) {

            $dealEnquiry = $jsonData->dealEnquiry ?? null;
            if ($dealEnquiry !== null) {
                $searchDealEnquiryRequestDataModel->dealEnquiry = DealEnquiryDataModel::fromJson($dealEnquiry);
            }


            $pagination = $jsonData->pagination ?? null;
            if ($pagination !== null) {
                $searchDealEnquiryRequestDataModel->pagination = PaginationDataModel::fromJson($pagination);
            }
        }

        return $searchDealEnquiryRequestDataModel;
    }
}