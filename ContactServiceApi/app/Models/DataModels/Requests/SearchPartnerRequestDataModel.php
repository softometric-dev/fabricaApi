<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\PartnerDataModel;
use App\Libraries\{ParameterException};

class SearchPartnerRequestDataModel extends PaginationRequestDataModel
{

    public $partner;
    public $pagination;

    public function __construct()
    {
        parent::__construct();
    }
    public function validateAndEnrichData()
    {
        $partner = $this->partner;
        $pagination = $this->pagination;

        // Validate mandatory inputs
        if (
            (
                empty($partner)
            ) &&
            empty($pagination) ||
            empty($pagination->currentPage) ||
            empty($pagination->pageSize)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'partner, currentPage, pageSize');
        }

        // Optional inputs and setting defaults
        // Add additional defaults here if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $searchPartnerRequestDataModel = new SearchPartnerRequestDataModel();

        if ($jsonData !== null) {

            $partner = $jsonData->partner ?? null;
            if ($partner !== null) {
                $searchPartnerRequestDataModel->partner = PartnerDataModel::fromJson($partner);
            }


            $pagination = $jsonData->pagination ?? null;
            if ($pagination !== null) {
                $searchPartnerRequestDataModel->pagination = PaginationDataModel::fromJson($pagination);
            }
        }

        return $searchPartnerRequestDataModel;
    }
}