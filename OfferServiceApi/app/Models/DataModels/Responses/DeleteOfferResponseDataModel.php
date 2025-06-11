<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\OfferDataModel;

class DeleteOfferResponseDataModel extends ApiResponseDataModel
{
    public $deletedOffer;
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
		$deleteOfferResponseDataModel = new DeleteOfferResponseDataModel();
		if ($jsonData != null) {
			$deletedOffer = $jsonData->deletedOffer ?? null;
			if ($deletedOffer != null) {
				$offerDataModel = OfferDataModel::fromJson($deletedOffer);
				$deleteOfferResponseDataModel->deletedOffer = $offerDataModel;
			}
		}
		return $deleteOfferResponseDataModel;
	}
}