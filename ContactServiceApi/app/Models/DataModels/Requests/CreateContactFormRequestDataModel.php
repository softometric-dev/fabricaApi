<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\ContactFormDataModel;
use App\Libraries\{ParameterException};

class CreateContactFormRequestDataModel extends ApiRequestDataModel
{
    public $newContactForm;

    public function __construct()
    {
        parent::__construct();
    }
    
    public function validateAndEnrichData()
    {
       
        $newContactForm = $this->newContactForm;
      	
        // Validate mandatory inputs
        if (
            is_null($newContactForm) ||
            empty($newContactForm->fullName) ||
            empty($newContactForm->phone)||
            empty($newContactForm->subject)||
            empty($newContactForm->email)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'fullName,phone,subject,email');
        }
    }

    public static function fromJson($jsonString)
	{
        
       
        $jsonData =  BaseDataModel::jsonDecode($jsonString);
		$createContactFormRequestDataModel = new CreateContactFormRequestDataModel();
     
        if ($jsonData !== null) {
            $newContactForm = isset($jsonData->newContactForm) ? $jsonData->newContactForm : null;	
            
            if($newContactForm !== null )
				{
					$contactFormDataModel = ContactFormDataModel::fromJson($newContactForm);	
					$createContactFormRequestDataModel->newContactForm = $contactFormDataModel;	
                    				
				}
        }

        return $createContactFormRequestDataModel;
    }

}