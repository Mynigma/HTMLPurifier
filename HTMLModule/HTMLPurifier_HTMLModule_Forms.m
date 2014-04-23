//
//   HTMLPurifier_HTMLModule_Forms.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_HTMLModule_Forms.h"
#import "HTMLPurifier_ElementDef.h"
#import "BasicPHP.h"
#import "HTMLPurifier_ChildDef_Chameleon.h"

@implementation HTMLPurifier_HTMLModule_Forms


- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super initWithConfig:config];
    if (self) {

        self.name = @"Forms";

        self.safe = NO;


//        public $content_sets = array(
//                                     'Block' => 'Form',
//                                     'Inline' => 'Formctrl',
//                                     );
//        $form = $this->addElement(
//                                  'form',
//                                  'Form',
//                                  'Required: Heading | List | Block | fieldset',
//                                  'Common',
//                                  array(
//                                        'accept' => 'ContentTypes',
//                                        'accept-charset' => 'Charsets',
//                                        'action*' => 'URI',
//                                        'method' => 'Enum#get,post',
//                                        // really ContentType, but these two are the only ones used today
//                                        'enctype' => 'Enum#application/x-www-form-urlencoded,multipart/form-data',
//                                        )
//                                  );
//        $form->excludes = array('form' => true);
//
//        $input = $this->addElement(
//                                   'input',
//                                   'Formctrl',
//                                   'Empty',
//                                   'Common',
//                                   array(
//                                         'accept' => 'ContentTypes',
//                                         'accesskey' => 'Character',
//                                         'alt' => 'Text',
//                                         'checked' => 'Bool#checked',
//                                         'disabled' => 'Bool#disabled',
//                                         'maxlength' => 'Number',
//                                         'name' => 'CDATA',
//                                         'readonly' => 'Bool#readonly',
//                                         'size' => 'Number',
//                                         'src' => 'URI#embedded',
//                                         'tabindex' => 'Number',
//                                         'type' => 'Enum#text,password,checkbox,button,radio,submit,reset,file,hidden,image',
//                                         'value' => 'CDATA',
//                                         )
//                                   );
//        $input->attr_transform_post[] = new HTMLPurifier_AttrTransform_Input();
//
//        $this->addElement(
//                          'select',
//                          'Formctrl',
//                          'Required: optgroup | option',
//                          'Common',
//                          array(
//                                'disabled' => 'Bool#disabled',
//                                'multiple' => 'Bool#multiple',
//                                'name' => 'CDATA',
//                                'size' => 'Number',
//                                'tabindex' => 'Number',
//                                )
//                          );
//
//        $this->addElement(
//                          'option',
//                          false,
//                          'Optional: #PCDATA',
//                          'Common',
//                          array(
//                                'disabled' => 'Bool#disabled',
//                                'label' => 'Text',
//                                'selected' => 'Bool#selected',
//                                'value' => 'CDATA',
//                                )
//                          );
//        // It's illegal for there to be more than one selected, but not
//        // be multiple. Also, no selected means undefined behavior. This might
//        // be difficult to implement; perhaps an injector, or a context variable.
//
//        $textarea = $this->addElement(
//                                      'textarea',
//                                      'Formctrl',
//                                      'Optional: #PCDATA',
//                                      'Common',
//                                      array(
//                                            'accesskey' => 'Character',
//                                            'cols*' => 'Number',
//                                            'disabled' => 'Bool#disabled',
//                                            'name' => 'CDATA',
//                                            'readonly' => 'Bool#readonly',
//                                            'rows*' => 'Number',
//                                            'tabindex' => 'Number',
//                                            )
//                                      );
//        $textarea->attr_transform_pre[] = new HTMLPurifier_AttrTransform_Textarea();
//
//        $button = $this->addElement(
//                                    'button',
//                                    'Formctrl',
//                                    'Optional: #PCDATA | Heading | List | Block | Inline',
//                                    'Common',
//                                    array(
//                                          'accesskey' => 'Character',
//                                          'disabled' => 'Bool#disabled',
//                                          'name' => 'CDATA',
//                                          'tabindex' => 'Number',
//                                          'type' => 'Enum#button,submit,reset',
//                                          'value' => 'CDATA',
//                                          )
//                                    );
//        
//        // For exclusions, ideally we'd specify content sets, not literal elements
//        $button->excludes = $this->makeLookup(
//                                              'form',
//                                              'fieldset', // Form
//                                              'input',
//                                              'select',
//                                              'textarea',
//                                              'label',
//                                              'button', // Formctrl
//                                              'a', // as per HTML 4.01 spec, this is omitted by modularization
//                                              'isindex',
//                                              'iframe' // legacy items
//                                              );
//        
//        // Extra exclusion: img usemap="" is not permitted within this element.
//        // We'll omit this for now, since we don't have any good way of
//        // indicating it yet.
//        
//        // This is HIGHLY user-unfriendly; we need a custom child-def for this
//        $this->addElement('fieldset', 'Form', 'Custom: (#WS?,legend,(Flow|#PCDATA)*)', 'Common');
//        
//        $label = $this->addElement(
//                                   'label',
//                                   'Formctrl',
//                                   'Optional: #PCDATA | Inline',
//                                   'Common',
//                                   array(
//                                         'accesskey' => 'Character',
//                                         // 'for' => 'IDREF', // IDREF not implemented, cannot allow
//                                         )
//                                   );
//        $label->excludes = array('label' => true);
//        
//        $this->addElement(
//                          'legend',
//                          false,
//                          'Optional: #PCDATA | Inline',
//                          'Common',
//                          array(
//                                'accesskey' => 'Character',
//                                )
//                          );
//        
//        $this->addElement(
//                          'optgroup',
//                          false,
//                          'Required: option',
//                          'Common',
//                          array(
//                                'disabled' => 'Bool#disabled',
//                                'label*' => 'Text',
//                                )
//                          );
    }
    return self;
}

- (id)init
{
    return [self initWithConfig:nil];
}



//- (HTMLPurifier_ChildDef_Chameleon*)getChildDef:(HTMLPurifier_ElementDef*)def
//{
//    if ([[def.content_model_type lowercaseString] isEqual:@"chameleon"])
//    {
//        return nil;
//    }
//    NSArray* value = explode(@"!", def.content_model);
//    return [[HTMLPurifier_ChildDef_Chameleon alloc] initWithInline:value[0] block: value[1]];
//}



@end
