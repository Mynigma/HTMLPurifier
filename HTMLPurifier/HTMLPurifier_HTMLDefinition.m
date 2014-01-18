//
//  HTMLPurifier_HTMLDefinition.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLDefinition.h"
#import "HTMLPurifier_HTMLModule.h"
#import "HTMLPurifier_HTMLModuleManager.h"
#import "HTMLPurifier_ElementDef.h"


@implementation HTMLPurifier_HTMLDefinition


- (id)init
{
    self = [super init];
    if (self) {
        _info = [NSMutableDictionary new];
        _info_global_attr = [NSMutableDictionary new];
        _info_parent = @"div";
        _info_block_wrapper = @"p";
        _info_tag_transform = [NSMutableDictionary new];
        _info_attr_transform_pre = [NSMutableArray new];
        _info_attr_transform_post = [NSMutableArray new];
        _info_content_sets = [NSMutableDictionary new];
        _info_injector = [NSMutableArray new];
        _anonModule = nil;
        _typeString = @"HTML";
        _manager = [HTMLPurifier_HTMLModuleManager new];
    }
    return self;
}

// RAW CUSTOMIZATION STUFF --------------------------------------------

/**
 * Adds a custom attribute to a pre-existing element
 * @note This is strictly convenience, and does not have a corresponding
 *       method in HTMLPurifier_HTMLModule
 * @param string $element_name Element name to add attribute to
 * @param string $attr_name Name of attribute
 * @param mixed $def Attribute definition, can be string or object, see
 *             HTMLPurifier_AttrTypes for details
 */
- (void)addAttribute:(NSString*)element_name attrName:(NSString*)attr_name def:(NSObject*)def
{
    HTMLPurifier_ElementDef* element;
    HTMLPurifier_HTMLModule* module = [self getAnonymousModule];
    if (!module.info[element_name]) {
        element = [module addBlankElement:element_name];
    } else {
        element = module.info[element_name];
    }
    element.attr[attr_name] = def;
}

/**
 * Adds a custom element to your HTML definition
 * @see HTMLPurifier_HTMLModule::addElement() for detailed
 *       parameter and return value descriptions.
 */
- (HTMLPurifier_ElementDef*)addElement:(NSString*)element_name type:(NSString*)type contents:(NSString*)contents attrCollections:(NSArray*)attr_collections attributes:(NSDictionary*)attributes
{
    HTMLPurifier_HTMLModule* module = [self getAnonymousModule];
    // assume that if the user is calling this, the element
    // is safe. This may not be a good idea
    HTMLPurifier_ElementDef* element = [module addElement:element_name type:type contents:contents attrIncludes:attr_collections attr:attributes];
    return element;
}

/**
 * Adds a blank element to your HTML definition, for overriding
 * existing behavior
 * @param string $element_name
 * @return HTMLPurifier_ElementDef
 * @see HTMLPurifier_HTMLModule::addBlankElement() for detailed
 *       parameter and return value descriptions.
 */
- (HTMLPurifier_ElementDef*)addBlankElement:(NSString*)element_name
{
    HTMLPurifier_HTMLModule* module  = [self getAnonymousModule];
    HTMLPurifier_ElementDef* element = [module addBlankElement:element_name];
    return element;
}

/**
 * Retrieves a reference to the anonymous module, so you can
 * bust out advanced features without having to make your own
 * module.
 * @return HTMLPurifier_HTMLModule
 */
- (HTMLPurifier_HTMLModule*)getAnonymousModule
{
    if (!self->_anonModule) {
        self->_anonModule = [HTMLPurifier_HTMLModule new];
        self->_anonModule.name = @"Anonymous";
    }
    return self->_anonModule;
}


/**
 * @param HTMLPurifier_Config $config
 */
- (void)doSetup:(HTMLPurifier_Config*)config
{
    [self processModules:config];
    [self setupConfigStuff:config];
    _manager = nil;

    // cleanup some of the element definitions
    for(NSString* k in _info) {
        HTMLPurifier_ElementDef* elementDef = _info[k];
        [elementDef setContent_model:nil];
        [elementDef setContent_model_type:nil];
    }
}

/**
 * Extract out the information from the manager
 * @param HTMLPurifier_Config $config
 */
- (void)processModules:(HTMLPurifier_Config*)config
{

}
/**
 * Sets up stuff based on config. We need a better way of doing this.
 * @param HTMLPurifier_Config $config
 */
- (void)setupConfigStuff:(HTMLPurifier_Config*)config
{

}
/**
 * Parses a TinyMCE-flavored Allowed Elements and Attributes list into
 * separate lists for processing. Format is element[attr1|attr2],element2...
 * @warning Although it's largely drawn from TinyMCE's implementation,
 *      it is different, and you'll probably have to modify your lists
 * @param array $list String list to parse
 * @return array
 * @todo Give this its own class, probably static interface
 */
- (NSDictionary*)parseTinyMCEAllowedList:(NSArray*)list
{
    return nil;
}



///**
// * Extract out the information from the manager
// * @param HTMLPurifier_Config $config
// */
//protected function processModules($config)
//{
//    if ($this->_anonModule) {
//        // for user specific changes
//        // this is late-loaded so we don't have to deal with PHP4
//        // reference wonky-ness
//        $this->manager->addModule($this->_anonModule);
//        unset($this->_anonModule);
//    }
//
//    $this->manager->setup($config);
//    $this->doctype = $this->manager->doctype;
//
//    foreach ($this->manager->modules as $module) {
//        foreach ($module->info_tag_transform as $k => $v) {
//            if ($v === false) {
//                unset($this->info_tag_transform[$k]);
//            } else {
//                $this->info_tag_transform[$k] = $v;
//            }
//        }
//        foreach ($module->info_attr_transform_pre as $k => $v) {
//            if ($v === false) {
//                unset($this->info_attr_transform_pre[$k]);
//            } else {
//                $this->info_attr_transform_pre[$k] = $v;
//            }
//        }
//        foreach ($module->info_attr_transform_post as $k => $v) {
//            if ($v === false) {
//                unset($this->info_attr_transform_post[$k]);
//            } else {
//                $this->info_attr_transform_post[$k] = $v;
//            }
//        }
//        foreach ($module->info_injector as $k => $v) {
//            if ($v === false) {
//                unset($this->info_injector[$k]);
//            } else {
//                $this->info_injector[$k] = $v;
//            }
//        }
//    }
//    $this->info = $this->manager->getElements();
//    $this->info_content_sets = $this->manager->contentSets->lookup;
//}
//
///**
// * Sets up stuff based on config. We need a better way of doing this.
// * @param HTMLPurifier_Config $config
// */
//- (void)setupConfigStuff:(HTMLPurifier_Config*)config
//{
//    block_wrapper = [config get:@"HTML.BlockWrapper"];
//    if (self->info_content_sets[@"Block"][block_wrapper]) {
//        self->info_block_wrapper = $block_wrapper;
//    } else {
//        TRIGGER_ERROR(@"Cannot use non-block element as block wrapper");
//    }
//
//    $parent = $config->get('HTML.Parent');
//    $def = $this->manager->getElement($parent, true);
//    if ($def) {
//        $this->info_parent = $parent;
//        $this->info_parent_def = $def;
//    } else {
//        trigger_error(
//                      'Cannot use unrecognized element as parent',
//                      E_USER_ERROR
//                      );
//        $this->info_parent_def = $this->manager->getElement($this->info_parent, true);
//    }
//
//    // support template text
//    $support = "(for information on implementing this, see the support forums) ";
//
//    // setup allowed elements -----------------------------------------
//
//    $allowed_elements = $config->get('HTML.AllowedElements');
//    $allowed_attributes = $config->get('HTML.AllowedAttributes'); // retrieve early
//
//    if (!is_array($allowed_elements) && !is_array($allowed_attributes)) {
//        $allowed = $config->get('HTML.Allowed');
//        if (is_string($allowed)) {
//            list($allowed_elements, $allowed_attributes) = $this->parseTinyMCEAllowedList($allowed);
//        }
//    }
//
//    if (is_array($allowed_elements)) {
//        foreach ($this->info as $name => $d) {
//            if (!isset($allowed_elements[$name])) {
//                unset($this->info[$name]);
//            }
//            unset($allowed_elements[$name]);
//        }
//        // emit errors
//        foreach ($allowed_elements as $element => $d) {
//            $element = htmlspecialchars($element); // PHP doesn't escape errors, be careful!
//            trigger_error("Element '$element' is not supported $support", E_USER_WARNING);
//        }
//    }
//
//    // setup allowed attributes ---------------------------------------
//
//    $allowed_attributes_mutable = $allowed_attributes; // by copy!
//    if (is_array($allowed_attributes)) {
//        // This actually doesn't do anything, since we went away from
//        // global attributes. It's possible that userland code uses
//        // it, but HTMLModuleManager doesn't!
//        foreach ($this->info_global_attr as $attr => $x) {
//            $keys = array($attr, "*@$attr", "*.$attr");
//            $delete = true;
//            foreach ($keys as $key) {
//                if ($delete && isset($allowed_attributes[$key])) {
//                    $delete = false;
//                }
//                if (isset($allowed_attributes_mutable[$key])) {
//                    unset($allowed_attributes_mutable[$key]);
//                }
//            }
//            if ($delete) {
//                unset($this->info_global_attr[$attr]);
//            }
//        }
//
//        foreach ($this->info as $tag => $info) {
//            foreach ($info->attr as $attr => $x) {
//                $keys = array("$tag@$attr", $attr, "*@$attr", "$tag.$attr", "*.$attr");
//                $delete = true;
//                foreach ($keys as $key) {
//                    if ($delete && isset($allowed_attributes[$key])) {
//                        $delete = false;
//                    }
//                    if (isset($allowed_attributes_mutable[$key])) {
//                        unset($allowed_attributes_mutable[$key]);
//                    }
//                }
//                if ($delete) {
//                    if ($this->info[$tag]->attr[$attr]->required) {
//                        trigger_error(
//                                      "Required attribute '$attr' in element '$tag' " .
//                                      "was not allowed, which means '$tag' will not be allowed either",
//                                      E_USER_WARNING
//                                      );
//                    }
//                    unset($this->info[$tag]->attr[$attr]);
//                }
//            }
//        }
//        // emit errors
//        foreach ($allowed_attributes_mutable as $elattr => $d) {
//            $bits = preg_split('/[.@]/', $elattr, 2);
//            $c = count($bits);
//            switch ($c) {
//                case 2:
//                    if ($bits[0] !== '*') {
//                        $element = htmlspecialchars($bits[0]);
//                        $attribute = htmlspecialchars($bits[1]);
//                        if (!isset($this->info[$element])) {
//                            trigger_error(
//                                          "Cannot allow attribute '$attribute' if element " .
//                                          "'$element' is not allowed/supported $support"
//                                          );
//                        } else {
//                            trigger_error(
//                                          "Attribute '$attribute' in element '$element' not supported $support",
//                                          E_USER_WARNING
//                                          );
//                        }
//                        break;
//                    }
//                    // otherwise fall through
//                case 1:
//                    $attribute = htmlspecialchars($bits[0]);
//                    trigger_error(
//                                  "Global attribute '$attribute' is not ".
//                                  "supported in any elements $support",
//                                  E_USER_WARNING
//                                  );
//                    break;
//            }
//        }
//    }
//
//    // setup forbidden elements ---------------------------------------
//
//    $forbidden_elements   = $config->get('HTML.ForbiddenElements');
//    $forbidden_attributes = $config->get('HTML.ForbiddenAttributes');
//
//    foreach ($this->info as $tag => $info) {
//        if (isset($forbidden_elements[$tag])) {
//            unset($this->info[$tag]);
//            continue;
//        }
//        foreach ($info->attr as $attr => $x) {
//            if (isset($forbidden_attributes["$tag@$attr"]) ||
//                isset($forbidden_attributes["*@$attr"]) ||
//                isset($forbidden_attributes[$attr])
//                ) {
//                unset($this->info[$tag]->attr[$attr]);
//                continue;
//            } elseif (isset($forbidden_attributes["$tag.$attr"])) { // this segment might get removed eventually
//                                                                    // $tag.$attr are not user supplied, so no worries!
//                trigger_error(
//                              "Error with $tag.$attr: tag.attr syntax not supported for " .
//                              "HTML.ForbiddenAttributes; use tag@attr instead",
//                              E_USER_WARNING
//                              );
//            }
//        }
//    }
//    foreach ($forbidden_attributes as $key => $v) {
//        if (strlen($key) < 2) {
//            continue;
//        }
//        if ($key[0] != '*') {
//            continue;
//        }
//        if ($key[1] == '.') {
//            trigger_error(
//                          "Error with $key: *.attr syntax not supported for HTML.ForbiddenAttributes; use attr instead",
//                          E_USER_WARNING
//                          );
//        }
//    }
//
//    // setup injectors -----------------------------------------------------
//    foreach ($this->info_injector as $i => $injector) {
//        if ($injector->checkNeeded($config) !== false) {
//            // remove injector that does not have it's required
//            // elements/attributes present, and is thus not needed.
//            unset($this->info_injector[$i]);
//        }
//    }
//}
//
///**
// * Parses a TinyMCE-flavored Allowed Elements and Attributes list into
// * separate lists for processing. Format is element[attr1|attr2],element2...
// * @warning Although it's largely drawn from TinyMCE's implementation,
// *      it is different, and you'll probably have to modify your lists
// * @param array $list String list to parse
// * @return array
// * @todo Give this its own class, probably static interface
// */
//public function parseTinyMCEAllowedList($list)
//{
//    $list = str_replace(array(' ', "\t"), '', $list);
//
//    $elements = array();
//    $attributes = array();
//
//    $chunks = preg_split('/(,|[\n\r]+)/', $list);
//    foreach ($chunks as $chunk) {
//        if (empty($chunk)) {
//            continue;
//        }
//        // remove TinyMCE element control characters
//        if (!strpos($chunk, '[')) {
//            $element = $chunk;
//            $attr = false;
//        } else {
//            list($element, $attr) = explode('[', $chunk);
//        }
//        if ($element !== '*') {
//            $elements[$element] = true;
//        }
//        if (!$attr) {
//            continue;
//        }
//        $attr = substr($attr, 0, strlen($attr) - 1); // remove trailing ]
//        $attr = explode('|', $attr);
//        foreach ($attr as $key) {
//            $attributes["$element.$key"] = true;
//        }
//    }
//    return array($elements, $attributes);
//}
//}


@end
