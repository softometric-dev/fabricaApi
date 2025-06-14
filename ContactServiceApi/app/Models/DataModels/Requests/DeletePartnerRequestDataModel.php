<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\PartnerDataModel;
use App\Libraries\{ParameterException};

class DeletePartnerRequestDataModel extends ApiRequestDataModel
{

    public $partnerToDelete;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $partnerToDelete = $this->partnerToDelete;

        // Validate mandatory inputs
        if (empty($partnerToDelete) || empty($partnerToDelete->partnerId)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'partnerId');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $deletePartnerRequestDataModel = new DeletePartnerRequestDataModel();

        if ($jsonData !== null) {
            $partnerToDelete = $jsonData->partnerToDelete ?? null;
            if ($partnerToDelete !== null) {
                $partnerDataModel = PartnerDataModel::fromJson($partnerToDelete);
                $deletePartnerRequestDataModel->partnerToDelete = $partnerDataModel;
            }
        }

        return $deletePartnerRequestDataModel;
    }

}