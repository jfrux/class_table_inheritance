<cfcomponent output="false" displayname="Class Table Inheritance" mixin="model">
	<!---

	--->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfset this.version = "1.1" />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="acts_as_superclass" access="public">
		<cfscript>
		if (listFindNoCase(this.columnNames(),"subtype",",")) {
		  /*def self.find(*args)
			super_classes = super
			begin
			  if super_classes.kind_of? Array
				super_classes.map do |item|
				  if !item.subtype.nil? && !item.subtype.blank?
					inherits_type = super_classes.subtype.to_s.classify.constantize
					inherits_type.send(:find, item.id)
				  else
					super_classes
				  end
				end
			  else
				if !super_classes.subtype.nil? && !super_classes.subtype.blank?
				  inherits_type = super_classes.subtype.to_s.classify.constantize
				  inherits_type.send(:find, *args)
				else
				  super_classes
				end
			  end
			rescue
			  super_classes
			end
		  end*/
		} 
		</cfscript>
	</cffunction>
	
	<cffunction name="inherits_from" access="public">
		<cfargument name="assoc_id" type="any" />
		
		<cfif NOT structKeyExists(variables.wheels.class,'class_table_inheritance')>
			<cfset variables.wheels.class['class_table_inheritance'] = {} />
		</cfif>
		
		<cfset $setAssocId(arguments.assoc_id) />
		
		<cfscript>
		// Subst the module simbol to dash and if this is string
		if (NOT isNumeric($getAssocId())) {
		  class_name = $getAssocId()
		  $setAssocId(lcase($getAssocId()));
		} else {
		  class_name = ToString($getAssocId());
		}
		
		// add an association, and set the foreign key.
		hasOne(name = $getAssocId(), modelName = class_name, foreignKey = primaryKey(), dependent = "delete");
	
		// set the primary key, it' need because the generalized table doesn't have
		// a field ID.
		setPrimaryKey("#$getAssocId()#_id");

		// Set a method chain whith autobuild.
		//alias_method_chain($getAssocId(), autobuild);
	
		// bind the before save, this method call the save of association, and
		// get our generated ID an set to association_id field.
		beforeSave("save_inherit");
	  
		// Bind the validation of association.
		validate("inherit_association_must_be_valid");
	
	  	// get the class of association by reflection, this is needed because
		$setAssocClass($getAssocId());
		
		association_class = $getAssocClass();
		
		// Get the columns of association class.
		//inherited_columns = association_class.columnNames();
		
		// Get the methods of the association class and turn it into an Array of Strings.
//		inherited_methods = [];
//		
//		//loop through all keys of the association_class and get only methods
//		for(key in association_class) {
//			if(isCustomFunction(association_class[key])) {
//				ArrayAppend(inherited_methods,ToString(key));
//			}
//		}
		
		// Make a filter in association methods to exclude the methods that
		// the sub class already have.
		//inherited_methods = reject(inherited_methods,$removeMethods);
		</cfscript>
	</cffunction>
	
	<!--- GETTER ASSOCIATION KEY NAME --->
	<cffunction name="$getAssocId">
		<cfreturn variables.wheels.class.class_table_inheritance.association_id />
	</cffunction>
	
	<!--- SETTER ASSOCIATION KEY NAME --->
	<cffunction name="$setAssocId">
		<cfargument name="assoc_id" />
		<cfset variables.wheels.class.class_table_inheritance['association_id'] = arguments.assoc_id />
	</cffunction>
	
	<!--- GETTER ASSOCIATION MODEL CLASS --->
	<cffunction name="$getAssocClass">
		<cfreturn variables.wheels.class.class_table_inheritance.association_class />
	</cffunction>
	
	<!--- SETTER ASSOCIATION MODEL CLASS --->
	<cffunction name="$setAssocClass">
		<cfargument name="assoc_id" />
		<cfset variables.wheels.class.class_table_inheritance.association_class = model(assoc_id) />
	</cffunction>
	
	<cffunction name="$_get" access="public">
		<cfscript>
		// if the field is ID than i only bind that with the association field.
		// this is needed to bypass the overflow problem when the ActiveRecord
		// try to get the id to find the association.
		if (arguments.name == 'id') {
			return this["#$getAssocId()#_id"];
		} else {
			assoc = model($getAssocId());
			evaluate('assoc.#arguments.name#()');
		}
		</cfscript>
	</cffunction>
	
	<cffunction name="$_set" access="public">
		<cfargument name="name" />
		<cfargument name="args" />
		
		<cfscript>
		// if the field is ID than i only bind that with the association field.
		// this is needed to bypass the overflow problem when the ActiveRecord
		// try to get the id to find the association.
		if(name == 'id') {
			this["#$getAssocId()#_id"] = args.new_value;
		} else {
			assoc = model($getAssocId());
			evaluate("assoc.#args.name# = args.new_value");
		}
		</cfscript>
	</cffunction>
	
	<cffunction name="$removeColumns" access="public">
		<cfargument name="c">
		
		<cfif structKeyExists(variables.wheels.class,'columnList')>
			<cfreturn (listFindNoCase(this.columnNames(),arguments.c,',')) || (arguments.c == "type") || (arguments.c == "subtype") />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="$removeMethods" access="public">
		<cfargument name="key">
		<cfargument name="index">
		<cfargument name="arr">
		
		<cfreturn (ArrayFindNoCase(structKeyList(this),arguments.key) GT 0) />
	</cffunction>
	
	<cffunction name="inherit_association_must_be_valid" access="public" hint="Generate a method to validate the field of association.">
		<cfscript>
		var association = model($getAssocId());
		
		/*if(this.valid() NEQ association.valid()) {
			for(error in assocation.errors) {
			  this.addError(attr, message)
			}
		} else {
			return this.valid();
		}*/
		</cfscript>
	</cffunction>
	
	<cffunction name="save_inherit" access="public">
		<cfscript>
		var association = model($getAssocId());
		
		if (listFindNoCase(association.propertyNames(),"subtype",",")) {
			association.subtype = ToString(this.subtype);
		}
		
		if(association.save()) {
			this["#$getAssocId()#_id"] = association.id
		
			return true;
		} else {
			writeDump(var=association.allErrors(),abort=true);
		}
		</cfscript>
	</cffunction>
	
	<cfscript>
	/**
	 * Like listFindNoCase(), but for arrays.
	 * 
	 * @param arrayToSearch 	 The array to search. (Required)
	 * @param valueToFind 	 The value to look for. (Required)
	 * @return Returns a number. 
	 * @author Nathan Dintenfass (&#110;&#97;&#116;&#104;&#97;&#110;&#64;&#99;&#104;&#97;&#110;&#103;&#101;&#109;&#101;&#100;&#105;&#97;&#46;&#99;&#111;&#109;) 
	 * @version 1, September 6, 2002 
	 */
	function ArrayFindNoCase(arrayToSearch,valueToFind){
		//a variable for looping
		var ii = 0;
		//loop through the array, looking for the value
		for(ii = 1; ii LTE arrayLen(arrayToSearch); ii = ii + 1){
			//if this is the value, return the index
			if(NOT compareNoCase(arrayToSearch[ii],valueToFind))
				return ii;
		}
		//if we've gotten this far, it means the value was not found, so return 0
		return 0;
	}
	</cfscript>
	
	<cffunction name="onMissingMethod" access="private">
		<cfset var loc = duplicate(arguments.MissingMethodArguments) />
		
		<cfif arguments.MissingMethodName CONTAINS "_with_autobuild">
			<cfreturn (evaluate("#loc.assocation_id#_without_autobuild()") || evaluate("build_#loc.assocation_id#")) />
		<cfelseif arguments.MissingMethodName CONTAINS "_get">
			<cfreturn $_get(argumentCollection=arguments.missingMethodArguments) />
		<cfelseif arguments.missingMethodName CONTAINS "_set">
			<cfreturn $_set(argumentCollection=arguments.missingMethodArguments) />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
</cfcomponent>