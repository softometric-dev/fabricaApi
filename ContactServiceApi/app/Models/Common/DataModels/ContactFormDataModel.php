<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;

class ContactFormDataModel extends BaseDataModel
{
    public $contactId;
    public $fullName;
    public $phone;
    public $email;
    public $comment;
    public $subject;
    public $contactFormModifiedDateTime;

     public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        // Add your validation and enrichment logic here
    }

    public static function fromJson($jsonString)
    {
        
        $jsonData = BaseDataModel::jsonDecode($jsonString);
       
        $contactFormDataModel = new ContactFormDataModel();

        if ($jsonData != null) {
          
            $contactFormDataModel->contactId = $jsonData->contactId ?? null;
            $contactFormDataModel->fullName = $jsonData->fullName ?? null;
            $contactFormDataModel->phone = $jsonData->phone ?? null;
            $contactFormDataModel->email = $jsonData->email ?? null;
            $contactFormDataModel->comment = $jsonData->comment ?? null;
            $contactFormDataModel->subject = $jsonData->subject ?? null;
            $contactFormDataModel->contactFormModifiedDateTime = $jsonData->contactFormModifiedDateTime ?? null;
            
        }

        return $contactFormDataModel;
    }

     public static function fromDbResultSet($dbResultSet)
    {
        $contactForms = [];

        if ($dbResultSet != null) {
            foreach ($dbResultSet as $row) {
                $contactForms[] = ContactFormDataModel::fromDbResultRow($row);
            }
        }

        return $contactForms;
    }

    public static function fromDbResultRow($row)
    {

        $contactForm = null;

        if ($row != null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $contactForm = new ContactFormDataModel();
            
            $contactForm->contactId = $objRow->contactId ?? null;
            $contactForm->fullName = $objRow->fullName ?? null;
            $contactForm->phone = $objRow->phone ?? null;
            $contactForm->email = $objRow->email ?? null;
            $contactForm->comment = $objRow->comment ?? null;
            $contactForm->subject = $objRow->subject ?? null;
            $contactForm->contactFormModifiedDateTime = $objRow->contactFormModifiedDateTime ?? null;
        }

        return $contactForm;
    }


     
}