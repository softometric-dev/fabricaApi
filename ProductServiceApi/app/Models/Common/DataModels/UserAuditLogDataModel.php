<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\UserBasicInfoDataModel;

class UserAuditLogDataModel extends BaseDataModel 
{

    public $userLoginAuditId;
        public $user;
		public $action;
		public $actionDateTime;
		public $deviceId;
		public $comments;
        
        // Constructor
        public function __construct()
        { 
            parent::__construct();
        }

		public function validateAndEnrichData()
		{
		}

        public static function fromJson($jsonString)
		{
            $jsonData = BaseDataModel::jsonDecode($jsonString);
			$userAuditLogDataModel = new UserAuditLogDataModel();
			if($jsonData != null)
			{				
                $userAuditLogDataModel->userLoginAuditId = $jsonData->userLoginAuditId ?? null;
                $userAuditLogDataModel->user = UserBasicInfoDataModel::fromJson($jsonData);
                $userAuditLogDataModel->action = $jsonData->action ?? null;
                $userAuditLogDataModel->actionDateTime = $jsonData->actionDateTime ?? null;
                $userAuditLogDataModel->deviceId = $jsonData->deviceId ?? null;
                $userAuditLogDataModel->comments = $jsonData->comments ?? null;
			}			
			return $userAuditLogDataModel;
		}

        public static function fromDbResultSet($dbResultSet)
		{
			$userAuditLogs = array();
			if($dbResultSet != null)
			{
				foreach($dbResultSet as  $row)
				{	
					$userAuditLogs[] = UserAuditLogDataModel::fromDbResultRow($row);
				}
			}			
			return $userAuditLogs;
		}

        public static function fromDbResultRow($row)
		{
			$userAuditLog = null;
			if($row != null)
			{
				$objRow = is_object($row) ? $row : (object)$row;
				$userAuditLog = new UserAuditLogDataModel();
				$userAuditLog->userLoginAuditId = property_exists($objRow,'userLoginAuditId') ? $objRow->userLoginAuditId : null;
				$userAuditLog->user = UserBasicInfoDataModel::fromDbResultRow($objRow);
				$userAuditLog->action = property_exists($objRow,'action') ? $objRow->action : null;
				$userAuditLog->actionDateTime = property_exists($objRow,'actionDateTime') ? $objRow->actionDateTime : null;
				$userAuditLog->deviceId = property_exists($objRow,'deviceId') ? $objRow->deviceId : null;
				$userAuditLog->comments = property_exists($objRow,'comments') ? $objRow->comments : null;
			}
			return $userAuditLog;
		}

}