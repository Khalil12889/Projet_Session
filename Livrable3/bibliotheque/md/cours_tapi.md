# COURS_TAPI






 
- [INS_COURS Function](#ins_cours)
 
- [UPD_COURS Function](#upd_cours)
 
- [DEL_COURS Function](#del_cours)
 
- [GET_COURS Function](#get_cours)












 
## INS_COURS Function<a name="ins_cours"></a>


<p>
<p>Description  procédure pour insérer un cours</p>
</p>

### Syntax
```plsql
FUNCTION ins_cours (
    p_credit cours.credit%type, p_nom_cours cours.nom_cours%type, p_description_cours cours.description_cours%type, p_test VARCHAR2 DEFAULT 'N'
) RETURN NUMBER
```

### Parameters
Name | Description
--- | ---
`p_derscription:` | description du cours
`p_sigle:` | sigle du cours ex. 420-3GB-BB
`p_credit:` | nombre de crédits du cours
`p_test:` | paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
*return* | id_cours: la clé primaire du cours créée
 
 


### Example
```plsql
cours_tapi.ins_cours ('','ABC');
```



 
## UPD_COURS Function<a name="upd_cours"></a>


<p>
<p>Description procédure pour mettre à jour un cours</p>
</p>

### Syntax
```plsql
FUNCTION upd_cours (
    p_credit IN cours.credit%type DEFAULT NULL, p_id_cours IN cours.id_cours%type, p_nom_cours IN cours.nom_cours%type DEFAULT NULL, p_description_cours IN cours.description_cours%type DEFAULT NULL, p_test VARCHAR2 DEFAULT 'N'
) RETURN NUMBER
```

### Parameters
Name | Description
--- | ---
`p_derscription:` | description du cours
`p_sigle:` | sigle du cours ex.: 420-3gb-bb
`p_credit:` | nombre de crédits du cours
`id_cours` | la clé primaire du cours à mettre à jour
*return* | sql%rowcount le nombre de rangées affectées
 
 


### Example
```plsql
cours_tapi.upd_cours (12,1,null,null);
```



 
## DEL_COURS Function<a name="del_cours"></a>


<p>
<p>Description procédure pour effacer un cours</p>
</p>

### Syntax
```plsql
FUNCTION del_cours (
    p_id_cours IN cours.id_cours%type, p_test VARCHAR2 DEFAULT 'N'
) RETURN NUMBER
```

### Parameters
Name | Description
--- | ---
`id_cours:` | la clé primaire du cours à mettre à jour
*return* | sql%rowcount le nombre de rangées affectées
 
 


### Example
```plsql
cours_tapi.del_cours (12);
```



 
## GET_COURS Function<a name="get_cours"></a>


<p>
<p>description procédure pour retourner les information d'un cours</p>
</p>

### Syntax
```plsql
FUNCTION get_cours (
    p_id_cours IN cours.id_cours%type
) RETURN VARCHAR2
```

### Parameters
Name | Description
--- | ---
`id_cours:` | la clé primaire du cours à mettre à jour
*return* | l_json_cours: tableau JSON qui contient les informations du cours
 
 


### Example
```plsql
cours_tapi.get_cours (12);
```



 
