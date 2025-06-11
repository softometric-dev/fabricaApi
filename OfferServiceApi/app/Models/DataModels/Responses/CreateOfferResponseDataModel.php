<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\OfferDataModel;

class CreateOfferResponseDataModel extends ApiResponseDataModel
{
    public $newOffer;

    public function __construct()
	{
		parent::__construct();
	}

	public function validateAndEnrichData()
	{
		//Validate mandatory inputs

		//Optional inputs and setting defaults			

	}

    public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$createOfferResponseDataModel = new CreateOfferResponseDataModel();
		if ($jsonData != null) {
			$newOffer = $jsonData->newOffer ?? null;
			if ($newOffer != null) {
				$offerDataModel = OfferDataModel::fromJson($newOffer);
				$createOfferResponseDataModel->newOffer = $offerDataModel;
			}



		}
		return $createOfferResponseDataModel;
	}

}