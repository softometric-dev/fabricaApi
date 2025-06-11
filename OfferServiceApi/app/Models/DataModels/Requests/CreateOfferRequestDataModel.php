<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\OfferDataModel;
use App\Libraries\{ParameterException};

class CreateOfferRequestDataModel extends ApiRequestDataModel
{
    public $newOffer;

    public function __construct()
    {
        parent::__construct();
    }
    
    public function validateAndEnrichData()
    {
       
        $newOffer = $this->newOffer;
      	
        // Validate mandatory inputs
        if (
            is_null($newOffer) ||
            empty($newOffer->offerName) ||
            empty($newOffer->title)||
            empty($newOffer->date)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'offerName,title,date');
        }
    }

    public static function fromJson($jsonString)
	{
        
       
        $jsonData =  BaseDataModel::jsonDecode($jsonString);
		$createOfferRequestDataModel = new CreateOfferRequestDataModel();
     
        if ($jsonData !== null) {
            $newOffer = isset($jsonData->newOffer) ? $jsonData->newOffer : null;	
            
            if($newOffer !== null )
				{
					$offerDataModel = OfferDataModel::fromJson($newOffer);	
					$createOfferRequestDataModel->newOffer = $offerDataModel;	
                    				
				}
        }

        return $createOfferRequestDataModel;
    }

}