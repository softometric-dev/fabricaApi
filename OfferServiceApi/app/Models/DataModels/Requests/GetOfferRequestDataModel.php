<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\OfferDataModel;
use App\Libraries\{ParameterException};

class GetOfferRequestDataModel extends ApiRequestDataModel
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
        if (empty($offer) || empty($offer->offerId)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'offerId');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $getOfferRequestDataModel = new GetOfferRequestDataModel();

        if ($jsonData !== null) {
            $offer = $jsonData->offer ?? null;
            if ($offer !== null) {
                $offerDataModel = OfferDataModel::fromJson($offer);
                $getOfferRequestDataModel->offer = $offerDataModel;
            }
        }

        return $getOfferRequestDataModel;
    }
}