<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\DealEnquiryDataModel;
use App\Libraries\{ParameterException};

class DeleteDealEnquiryRequestDataModel extends ApiRequestDataModel
{

    public $dealEnquiryToDelete;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $dealEnquiryToDelete = $this->dealEnquiryToDelete;

        // Validate mandatory inputs
        if (empty($dealEnquiryToDelete) || empty($dealEnquiryToDelete->dealEnquiryId)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'dealEnquiryId');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $deleteDealEnquiryRequestDataModel = new DeleteDealEnquiryRequestDataModel();

        if ($jsonData !== null) {
            $dealEnquiryToDelete = $jsonData->dealEnquiryToDelete ?? null;
            if ($dealEnquiryToDelete !== null) {
                $dealEnquiryDataModel = DealEnquiryDataModel::fromJson($dealEnquiryToDelete);
                $deleteDealEnquiryRequestDataModel->dealEnquiryToDelete = $dealEnquiryDataModel;
            }
        }

        return $deleteDealEnquiryRequestDataModel;
    }

}