<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\OfferDataModel;
use App\Libraries\{ParameterException};

class UpdateOfferRequestDataModel extends ApiRequestDataModel
{
    public $offer;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $offer = $this->offer;

        // Validate mandatory inputs
        if (empty($offer) || empty($offer->offerId) || empty($offer->offerModifiedDateTime)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'offerId, offerModifiedDateTime');
        }

        // Optional inputs and setting defaults
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $updateOfferRequestDataModel = new UpdateOfferRequestDataModel();

      
        if ($jsonData !== null) {
            $offer = $jsonData->offer ?? null;

            if ($offer !== null) {
         
                $offerDataModel = OfferDataModel::fromJson($offer);

                $updateOfferRequestDataModel->offer = $offerDataModel;
            }
        }

        return $updateOfferRequestDataModel;
    }
}