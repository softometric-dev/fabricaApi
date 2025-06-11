<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\OfferDataModel;
use App\Libraries\{ParameterException};

class DeleteOfferRequestDataModel extends ApiRequestDataModel
{

    public $offerToDelete;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $offerToDelete = $this->offerToDelete;

        // Validate mandatory inputs
        if (empty($offerToDelete) || empty($offerToDelete->offerId)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'offerId');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $deleteOfferRequestDataModel = new DeleteOfferRequestDataModel();

        if ($jsonData !== null) {
            $offerToDelete = $jsonData->offerToDelete ?? null;
            if ($offerToDelete !== null) {
                $offerDataModel = OfferDataModel::fromJson($offerToDelete);
                $deleteOfferRequestDataModel->offerToDelete = $offerDataModel;
            }
        }

        return $deleteOfferRequestDataModel;
    }

}