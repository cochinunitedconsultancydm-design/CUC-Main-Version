const amplifyConfig = '''{
  "auth": {
    "user_pool_id": "ap-south-2_7lQGNLJsx",
    "aws_region": "ap-south-2",
    "user_pool_client_id": "1rodvf4tco9rusi4afm7c68j88",
    "identity_pool_id": "ap-south-2:11a398e0-7f1e-4ea6-8069-b2c97df8a2d2",
    "mfa_methods": [],
    "standard_required_attributes": [
      "email"
    ],
    "username_attributes": [
      "email"
    ],
    "user_verification_types": [
      "email"
    ],
    "groups": [],
    "mfa_configuration": "NONE",
    "password_policy": {
      "min_length": 8,
      "require_lowercase": true,
      "require_numbers": true,
      "require_symbols": true,
      "require_uppercase": true
    },
    "unauthenticated_identities_enabled": true
  },
  "data": {
    "url": "https://wboqgyt4kvhhleihmtmwb6m42m.appsync-api.ap-south-2.amazonaws.com/graphql",
    "aws_region": "ap-south-2",
    "default_authorization_type": "AWS_IAM",
    "authorization_types": [
      "AMAZON_COGNITO_USER_POOLS"
    ],
    "model_introspection": {
      "version": 1,
      "models": {
        "Approvals": {
          "name": "Approvals",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "status": {
              "name": "status",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "approved_at": {
              "name": "approved_at",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "rejected_at": {
              "name": "rejected_at",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "reject_reason": {
              "name": "reject_reason",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Approvals",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "ActivityLogs": {
          "name": "ActivityLogs",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "user_id": {
              "name": "user_id",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "action": {
              "name": "action",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "target_type": {
              "name": "target_type",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "target_id": {
              "name": "target_id",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "details": {
              "name": "details",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "created_at": {
              "name": "created_at",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "ActivityLogs",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Billings": {
          "name": "Billings",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "invoice_no": {
              "name": "invoice_no",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "client_name": {
              "name": "client_name",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "date": {
              "name": "date",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "amount": {
              "name": "amount",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "type": {
              "name": "type",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "category": {
              "name": "category",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "authorities": {
              "name": "authorities",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "status": {
              "name": "status",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "payment_received": {
              "name": "payment_received",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Billings",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Cases": {
          "name": "Cases",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "client_id": {
              "name": "client_id",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "title": {
              "name": "title",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "case_number": {
              "name": "case_number",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "status": {
              "name": "status",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "court_details": {
              "name": "court_details",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "next_hearing_date": {
              "name": "next_hearing_date",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Cases",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "ChamberDocuments": {
          "name": "ChamberDocuments",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "title": {
              "name": "title",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "file_path": {
              "name": "file_path",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "category": {
              "name": "category",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "uploaded_by": {
              "name": "uploaded_by",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "version": {
              "name": "version",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "ChamberDocuments",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Clients": {
          "name": "Clients",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "name": {
              "name": "name",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "email": {
              "name": "email",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "phone": {
              "name": "phone",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "address": {
              "name": "address",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "balance_due": {
              "name": "balance_due",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "type_of_work": {
              "name": "type_of_work",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Clients",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "ClientDocuments": {
          "name": "ClientDocuments",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "client_id": {
              "name": "client_id",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "title": {
              "name": "title",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "file_path": {
              "name": "file_path",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "uploaded_by": {
              "name": "uploaded_by",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "is_signed": {
              "name": "is_signed",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "ClientDocuments",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "DailyCasePayments": {
          "name": "DailyCasePayments",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "case_id": {
              "name": "case_id",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "amount": {
              "name": "amount",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "payment_date": {
              "name": "payment_date",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "payment_mode": {
              "name": "payment_mode",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "received_by": {
              "name": "received_by",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "remarks": {
              "name": "remarks",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "DailyCasePayments",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "DocumentAuditLogs": {
          "name": "DocumentAuditLogs",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "document_id": {
              "name": "document_id",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "action": {
              "name": "action",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "user_id": {
              "name": "user_id",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "details": {
              "name": "details",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "DocumentAuditLogs",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Deals": {
          "name": "Deals",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "name": {
              "name": "name",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "client_id": {
              "name": "client_id",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "stage": {
              "name": "stage",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "amount": {
              "name": "amount",
              "isArray": false,
              "type": "Float",
              "isRequired": false,
              "attributes": []
            },
            "description": {
              "name": "description",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "is_won": {
              "name": "is_won",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Deals",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Expenses": {
          "name": "Expenses",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "title": {
              "name": "title",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "amount": {
              "name": "amount",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "category": {
              "name": "category",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "date": {
              "name": "date",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "description": {
              "name": "description",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Expenses",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "InwardPosts": {
          "name": "InwardPosts",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "sender": {
              "name": "sender",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "received_date": {
              "name": "received_date",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "subject": {
              "name": "subject",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "status": {
              "name": "status",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "assigned_to": {
              "name": "assigned_to",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "InwardPosts",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Leads": {
          "name": "Leads",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "name": {
              "name": "name",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "email": {
              "name": "email",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "phone": {
              "name": "phone",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "status": {
              "name": "status",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "source": {
              "name": "source",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Leads",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Meetings": {
          "name": "Meetings",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "title": {
              "name": "title",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "meeting_date": {
              "name": "meeting_date",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "location": {
              "name": "location",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "attendees": {
              "name": "attendees",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Meetings",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Messages": {
          "name": "Messages",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "sender_id": {
              "name": "sender_id",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "receiver_id": {
              "name": "receiver_id",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "content": {
              "name": "content",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "sent_at": {
              "name": "sent_at",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "is_read": {
              "name": "is_read",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Messages",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "StaffAttendance": {
          "name": "StaffAttendance",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "user_id": {
              "name": "user_id",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "check_in_time": {
              "name": "check_in_time",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "check_out_time": {
              "name": "check_out_time",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "attendance_date": {
              "name": "attendance_date",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "StaffAttendances",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Tasks": {
          "name": "Tasks",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "title": {
              "name": "title",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "description": {
              "name": "description",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "assigned_to": {
              "name": "assigned_to",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "status": {
              "name": "status",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "due_date": {
              "name": "due_date",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Tasks",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Users": {
          "name": "Users",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "username": {
              "name": "username",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "password": {
              "name": "password",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "role": {
              "name": "role",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "name": {
              "name": "name",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "email": {
              "name": "email",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Users",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "VaultFiles": {
          "name": "VaultFiles",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "file_name": {
              "name": "file_name",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "storage_path": {
              "name": "storage_path",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "uploaded_by": {
              "name": "uploaded_by",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "is_encrypted": {
              "name": "is_encrypted",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "VaultFiles",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Checklists": {
          "name": "Checklists",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "title": {
              "name": "title",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "description": {
              "name": "description",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "status": {
              "name": "status",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "assigned_to": {
              "name": "assigned_to",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Checklists",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "ChatMessages": {
          "name": "ChatMessages",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "sender": {
              "name": "sender",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "receiver": {
              "name": "receiver",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "message": {
              "name": "message",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "timestamp": {
              "name": "timestamp",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "ChatMessages",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "CommunicationLogs": {
          "name": "CommunicationLogs",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "client_id": {
              "name": "client_id",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "medium": {
              "name": "medium",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "notes": {
              "name": "notes",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "date": {
              "name": "date",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "CommunicationLogs",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "DocumentTemplates": {
          "name": "DocumentTemplates",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "name": {
              "name": "name",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "description": {
              "name": "description",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "file_path": {
              "name": "file_path",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "DocumentTemplates",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "ServiceItems": {
          "name": "ServiceItems",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "name": {
              "name": "name",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "price": {
              "name": "price",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "category": {
              "name": "category",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "data": {
              "name": "data",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "ServiceItems",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "identityPool",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        }
      },
      "enums": {},
      "nonModels": {}
    }
  },
  "storage": {
    "aws_region": "ap-south-2",
    "bucket_name": "amplify-legal-admin-sandb-legalstoragebucketd0b32d-fzcnyz2o47ht",
    "buckets": [
      {
        "name": "legalStorage",
        "bucket_name": "amplify-legal-admin-sandb-legalstoragebucketd0b32d-fzcnyz2o47ht",
        "aws_region": "ap-south-2",
        "paths": {
          "client-files/*": {
            "guest": [
              "get",
              "list",
              "write",
              "delete"
            ],
            "authenticated": [
              "get",
              "list",
              "write",
              "delete"
            ]
          },
          "vault/*": {
            "guest": [
              "get",
              "list",
              "write",
              "delete"
            ],
            "authenticated": [
              "get",
              "list",
              "write",
              "delete"
            ]
          }
        }
      }
    ]
  },
  "version": "1.4"
}''';
