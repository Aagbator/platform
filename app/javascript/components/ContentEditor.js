import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import CKEditor from '@ckeditor/ckeditor5-react';
import Rails from '@rails/ujs';

// Non-ckeditor React imports
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
//import 'react-tabs/style/react-tabs.css';

// Non-ckeditor Node imports
const uuidv4 = require('uuid/v4');

// The official CKEditor 5 instance inspector. It helps understand the editor view and model.
import CKEditorInspector from '@ckeditor/ckeditor5-inspector';

// NOTE: Use the editor from source (not a build)!
import BalloonEditor from '@ckeditor/ckeditor5-editor-balloon/src/ballooneditor';

import Essentials from '@ckeditor/ckeditor5-essentials/src/essentials';
import Autoformat from '@ckeditor/ckeditor5-autoformat/src/autoformat';
import BlockQuote from '@ckeditor/ckeditor5-block-quote/src/blockquote';
import BlockToolbar from '@ckeditor/ckeditor5-ui/src/toolbar/block/blocktoolbar';
import Bold from '@ckeditor/ckeditor5-basic-styles/src/bold';
import Heading from '@ckeditor/ckeditor5-heading/src/heading';
import Image from '@ckeditor/ckeditor5-image/src/image';
import ImageCaption from '@ckeditor/ckeditor5-image/src/imagecaption';
import ImageStyle from '@ckeditor/ckeditor5-image/src/imagestyle';
import ImageToolbar from '@ckeditor/ckeditor5-image/src/imagetoolbar';
import ImageUpload from '@ckeditor/ckeditor5-image/src/imageupload';
import Indent from '@ckeditor/ckeditor5-indent/src/indent';
import Italic from '@ckeditor/ckeditor5-basic-styles/src/italic';
import Link from '@ckeditor/ckeditor5-link/src/link';
import List from '@ckeditor/ckeditor5-list/src/list';
import MediaEmbed from '@ckeditor/ckeditor5-media-embed/src/mediaembed';
import Paragraph from '@ckeditor/ckeditor5-paragraph/src/paragraph';
import PasteFromOffice from '@ckeditor/ckeditor5-paste-from-office/src/pastefromoffice';
import Table from '@ckeditor/ckeditor5-table/src/table';
import TableToolbar from '@ckeditor/ckeditor5-table/src/tabletoolbar';
import Underline from '@ckeditor/ckeditor5-basic-styles/src/underline';
import SimpleUploadAdapter from '@ckeditor/ckeditor5-upload/src/adapters/simpleuploadadapter';
import Autosave from '@ckeditor/ckeditor5-autosave/src/autosave';
import OperationFactory from '@ckeditor/ckeditor5-engine/src/model/operation/operationfactory';

// CKEditor plugin implementing a content part widget to be used in the editor content.
import ContentPartPreviewEditing from '../ckeditor/contentpartpreviewediting';
import ContentCommonEditing from '../ckeditor/contentcommonediting';
import ChecklistQuestionEditing from '../ckeditor/checklistquestionediting';
import RadioQuestionEditing from '../ckeditor/radioquestionediting';
import TextAreaQuestionEditing from '../ckeditor/textareaquestionediting';
import RateThisModuleQuestionEditing from '../ckeditor/ratethismodulequestionediting';
import MatchingQuestionEditing from '../ckeditor/matchingquestionediting';
import TableContentEditing from '../ckeditor/tablecontentediting';
import BlockquoteContentEditing from '../ckeditor/blockquotecontentediting';
import IFrameContentEditing from '../ckeditor/iframecontentediting';
import VideoContentEditing from '../ckeditor/videocontentediting';
import SectionEditing from '../ckeditor/sectionediting';

import Tooltip from '../ckeditor/tooltip';
import ImageLink from '../ckeditor/imagelink';
import CustomElementAttributePreservation from '../ckeditor/customelementattributepreservation';

// React components to render the list of content parts and the content part preview.
import ContentPartList from './ContentPartList';
import ContentPartPreview from './ContentPartPreview';

// Plugins to include in the build.
BalloonEditor.builtinPlugins = [
    Essentials,
    Autoformat,
    BlockQuote,
    BlockToolbar,
    Bold,
    Heading,
    Image,
    ImageCaption,
    ImageStyle,
    ImageToolbar,
    ImageUpload,
    Indent,
    Italic,
    Link,
    Tooltip,
    ImageLink,
    List,
    MediaEmbed,
    Paragraph,
    PasteFromOffice,
    Table,
    TableToolbar,
    SimpleUploadAdapter,
    Autosave,

    ContentPartPreviewEditing,
    ContentCommonEditing,
    ChecklistQuestionEditing,
    RadioQuestionEditing,
    TextAreaQuestionEditing,
    RateThisModuleQuestionEditing,
    MatchingQuestionEditing,
    TableContentEditing,
    BlockquoteContentEditing,
    IFrameContentEditing,
    VideoContentEditing,
    SectionEditing,
];

// Editor configuration.
BalloonEditor.defaultConfig = {
    extraPlugins: [ CustomElementAttributePreservation ],
    blockToolbar: [
        'heading',
        '|',
        'bulletedList',
        'numberedList',
        '|',
        'indent',
        'outdent',
        '|',
        'imageUpload',
        'blockQuote',
        'insertTable',
        'mediaEmbed',
        '|',
        'undo',
        'redo'
    ],
    toolbar: {
        items: [
            'heading',
            '|',
            'bold',
            'italic',
            'link',
            'addTooltip',
            'bulletedList',
            'numberedList',
            '|',
            'indent',
            'outdent',
            '|',
            'imageUpload',
            'blockQuote',
            'insertTable',
            'undo',
            'redo'
        ]
    },
    image: {
        toolbar: [
            'imageStyle:full',
            'imageStyle:side',
            '|',
            'imageTextAlternative'
        ]
    },
    table: {
        contentToolbar: [
            'tableColumn',
            'tableRow',
            'mergeTableCells'
        ]
    },
    simpleUpload: {
        // The URL that the images are uploaded to.
        uploadUrl: '/image_upload_api',

        // Headers sent along with the XMLHttpRequest to the upload server.
        headers: {
            //Authorization: 'Bearer <JSON Web Token>'
            'X-CSRF-Token': Rails.csrfToken(),
        }
    },
    // This value must be kept in sync with the language defined in webpack.config.js.
    language: 'en',
};

function addRetainedDataID(element) {
   console.log('todo');
   return uuidv4();
}

window.addRetainedDataID = addRetainedDataID;

class ContentEditor extends Component {
    constructor( props ) {
        super( props );

        // A place to store the reference to the editor instance created by the <CKEditor> component.
        // The editor instance is created asynchronously and is only available when the editor is ready.
        this.editor = null;

        this.state = {
            // The initial editor data. It is bound to the editor instance and will change as
            // the user types and modifies the content of the editor.
            editorData: props.course_content['body'] || "",
            isPublished: false,
            enabledCommands: [],
            modelPath: [],
            viewPath: [],
            selectedElement: undefined,
        };

        // Need to be able to access this inside the config below.
        const saveData = this.saveData.bind( this );

        // The configuration of the <CKEditor> instance.
        this.editorConfig = {
            // The configuration of the ContentParts plugin. It specifies a function that will allow
            // the editor to render a React <ContentPartPreview> component inside a contentPart widget.
            contentParts: {
                contentPartRenderer: ( id, domElement ) => {
                    const contentPart = this.props.contentParts.find( contentPart => contentPart.id === id );

                    ReactDOM.render(
                        <ContentPartPreview id={id} {...contentPart} />,
                        domElement
                    );
                }
            },
            // Autosave
            autosave: {
                save( editor ) {
                    return saveData( editor.getData() );
                }
            }
        };

        this.handleEditorDataChange = this.handleEditorDataChange.bind( this );
        this.handleEditorFocusChange = this.handleEditorFocusChange.bind( this );

        this.handleEditorInit = this.handleEditorInit.bind( this );

        // Non-CKE UI functions.
        this.fileUpload = React.createRef();
        this.showFileUpload = this.showFileUpload.bind(this);
    }

    showFileUpload() {
        this.fileUpload.current.click();
    }

    saveData( data ) {
       this.setState( {
           'saveState': 'saving',
           'saveStateMessage': 'Saving...'
       } );

       // Save undo stack!
       // FIXME: Batch these and save only new ones.
       // hash key:operation value:saved?
       // only re-send things that are false
       // mark them true in the 200 block
       // use the undo command internal batch stacks
       this.editor.model.document.history.getOperations().forEach((operation) => {
           fetch("/course_content_undos.json", {
                   method: 'POST',
                   body: JSON.stringify({
                       course_content_id: this.props.course_content['id'],
                       operation: JSON.stringify(operation.toJSON()),
                       version: operation.baseVersion
                   }),
                   headers: {
                       'Content-Type': 'application/json',
                       'X-CSRF-Token': Rails.csrfToken()
                   }
               })
               .then(res => res.json())
               .then(
                   (result) => {
                       console.log('saved undo stack');
                   },
                   // Note: it's important to handle errors here
                   // instead of a catch() block so that we don't swallow
                   // exceptions from actual bugs in components.
                   (error) => {
                       // FIXME: silently ignore because this is probably just a unique violation
                       console.log(error);
                   }
               );
        });

       // Save contents.
       return fetch(`/course_contents/${this.props.course_content['id']}.json`, {
               method: 'PUT',
               body: JSON.stringify({body: data}), // data can be `string` or {object}!
               headers: {
                   'Content-Type': 'application/json',
                   'X-CSRF-Token': Rails.csrfToken()
               }
           })
           .then(res => res.json())
           .then(
               (result) => {
                   this.setState( {
                       'saveState': 'saved',
                       'saveStateMessage': 'Saved'
                   } );
               },
               // Note: it's important to handle errors here
               // instead of a catch() block so that we don't swallow
               // exceptions from actual bugs in components.
               (error) => {
                   console.log(error);
                   this.setState( {
                       'saveState': 'error',
                       'saveStateMessage': 'Error!'
                   } );
               }
           );
    }

    showFileUpload() {
        this.fileUpload.current.click();
    }

    // A handler executed when the user types or modifies the editor content.
    // It updates the state of the application.
    handleEditorDataChange( evt, editor ) {
        this.setState( {
            editorData: editor.getData(),
            isPublished: false
        } );
    }

    // A handler executed when the current selection changes inside the CKEditor view.
    // It propogates state changes from CKEditor up to this React component, so we can
    // update the UI accordingly.
    handleEditorFocusChange() {
        // Get the model element names of the current element and all its ancestors.
        const modelSelection = this.editor.model.document.selection;
        // If the current selection is an element (as opposed to inside an editable),
        // use that as the last node in the path. Otherwise use the parent of the last
        // cursor position (generally, the editable element the cursor is inside).
        const selectedModelElement = modelSelection.getSelectedElement() || modelSelection.getLastPosition().parent;
        const modelAncestorNames = selectedModelElement.getAncestors().map( x => x.name );

        const commands = this.editor.commands;

        this.setState( {
            enabledCommands: [...commands.names()].filter( x => commands.get(x).isEnabled ),
            modelPath: modelAncestorNames.concat(selectedModelElement.name),
            selectedElement: selectedModelElement
        } );

        // The view selection works differently than the model selection, and we can't
        // always tie it to an element. Only update the view path if it's sane.
        const viewSelection = this.editor.editing.view.document.selection;
        let selectedViewElement;
        if ( viewSelection.getSelectedElement() ) {
            // If the current selection is an element (as opposed to inside an editable),
            // use that as the last node in the path.
            selectedViewElement = viewSelection.getSelectedElement();
        } else if ( viewSelection.focus ) {
            // If the current selection has a focus, use the focus's parent as the last
            // node in the path.
            selectedViewElement = viewSelection.focus.parent;
        }

        // If one of the above cases was true, we'll have a selectedViewElement, and we can
        // pull its ancestor chain.
        if ( selectedViewElement ) {
            const viewAncestorNames = selectedViewElement.getAncestors().map( x => x.name );

            this.setState( {
                viewPath: viewAncestorNames.concat(selectedViewElement.name)
            } );
        }
    }

    // A handler executed when the user types or modifies the raw html editor content.
    // It updates the state of the application.
    handleHTMLEditorDataChange( evt ) {
        this.setState( {
            editorData: evt.target.value,
            isPublished: false
        } );
    }

    // A handler executed when the editor has been initialized and is ready.
    // It synchronizes the initial data state and saves the reference to the editor instance.
    handleEditorInit( editor ) {
        this.editor = editor;

        // Store a reference to the editor in the window, just to make debugging easier.
        window.editor = editor;

        this.setState( {
            editorData: editor.getData()
        } );

        // Attach the focus handler, and call it once to set the initial state of the right sidebar buttons.
        editor.editing.view.document.selection.on('change', this.handleEditorFocusChange);
        this.handleEditorFocusChange();

        // Populate undo history.
        console.log(this.props.undos);
        //this.editor.model.document.history._operations.pop();
        var batch = this.editor.model.createBatch('transparent');
        this.props.undos.sort((a, b)=>{return parseInt(a['version']) - parseInt(b['version'])}).forEach((operation_data) => {
            // TODO: add the operation to a batch, then apply it? Make sure the batch is 'transparent'.
            if (operation_data.version == 0) {
                return;
            }
            var operation = OperationFactory.fromJSON(JSON.parse(operation_data.operation), this.editor.model.document);
            console.log(operation);
            this.editor.model.document.history.addOperation(operation);
            batch.addOperation(operation);
            this.editor.model.document.version = Math.max(this.editor.model.document.version || 0, operation.baseVersion);
        });
        console.log(batch);
        if (batch.operations.length > 0) {
            this.editor.model.document.version = this.editor.model.document.version + 1;
            this.editor.commands.get('undo').addBatch(batch);
        }

        // CKEditor 5 inspector allows you to take a peek into the editor's model and view
        // data layers. Use it to debug the application and learn more about the editor.
        // Disable unless debug mode is enabled.
        if ( window.location.search === '?debug' ) {
            CKEditorInspector.attach( editor );
        }
    }

    handlePublish( evt ) {
        fetch(`/course_contents/${this.props.course_content['id']}/publish.json`, {
                method: 'POST',
                body: JSON.stringify(this.props.course_content), // data can be `string` or {object}!
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': Rails.csrfToken()
                }
            })
            .then(res => res.json())
            .then(
                (result) => {
                    this.setState( {'isPublished': true} );
                    // TODO: provide a way for the user to easily view the result, which will be in:
                    // `${CANVAS_URL}/courses/${result['course_id']}/pages/${result['secondary_id']}`
                },
                // Note: it's important to handle errors here
                // instead of a catch() block so that we don't swallow
                // exceptions from actual bugs in components.
                // TODO: We'll eventually want to actually handle errors, not just log them.
                (error) => {
                    console.log(error);
                }
            );
    }

    render() {
            // The application renders two columns:
            // * in the left one, the <CKEditor> and the textarea displaying live
            //   editor data are rendered.
            // * in the right column, a <ContentPartList> is rendered with available <ContentPartPreviews>
            //   to choose from.
        return (
            <div id="container" key="content-editor">
                <header>
                    <h1>Braven Content Editor</h1>
                    <span id="autosave-indicator" className={this.state['saveState']}>{this.state['saveStateMessage']}</span>

                    <ul>
                        <li onClick={(evt) => this.handlePublish(evt)} className={this.state['isPublished'] ? "success" : ""}>
                          Publish{this.state['isPublished'] ? "ed" : ""} {this.state['isPublished']}
                        </li>
                    </ul>

                </header>

                <main>
                    <div id="vertical-toolbar">
                        <div id="toolbar-page-settings">
                            <h4>Page Details</h4>
                            <ul id="edit-page">
                                <li><i className="fas fa-trash-alt"></i></li>
                                <li className="active"><i className="fas fa-copy"></i></li>
                            </ul>
                            <h2>
                                <input type="text" name="course_content[title]"
                                       defaultValue={this.props.course_content['title']}
                                       placeholder="Page Title"
                                />
                            </h2>
                        </div>
                        <div id="toolbar-contextual">
                            {this.state.modelPath.map( modelElement => {
                                if ( ['textArea', 'textInput'].includes( modelElement ) ) {
                                    // Text inputs and textareas have placeholder settings.
                                    const commandMap = {
                                        'textArea': 'insertTextArea',
                                        'textInput': 'insertTextInput',
                                    }
                                    return (
                                        <>
                                            <h4>Text Input</h4>
                                            <input
                                                type='text'
                                                id='input-placeholder'
                                                defaultValue={this.state['selectedElement'].getAttribute('placeholder')}
                                                onChange={( evt ) => {
                                                    this.editor.execute( commandMap[modelElement], 'retained-data-todo', evt.target.value );
                                                }}
                                            />
                                            <label htmlFor='input-placeholder'>Placeholder</label>
                                        </>
                                    );
                                } else if ( 'slider' === modelElement ) {
                                    // Sliders have several different settings to change.
                                    const min = this.state['selectedElement'].getAttribute('min');
                                    const max = this.state['selectedElement'].getAttribute('max');
                                    const step = this.state['selectedElement'].getAttribute('step');

                                    return (
                                        <>
                                            <h4>Slider</h4>

                                            <input
                                                type='number'
                                                id='input-min'
                                                defaultValue={min}
                                                onChange={( evt ) => {
                                                    this.editor.execute( 'insertSlider', 'retained-data-todo', {
                                                        min: evt.target.value,
                                                        max: max,
                                                        step: step,
                                                    } );
                                                }}
                                            />
                                            <label htmlFor='input-min'>Min</label>

                                            <input
                                                type='number'
                                                id='input-max'
                                                defaultValue={max}
                                                onChange={( evt ) => {
                                                    this.editor.execute( 'insertSlider', 'retained-data-todo', {
                                                        min: min,
                                                        max: evt.target.value,
                                                        step: step,
                                                    } );
                                                }}
                                            />
                                            <label htmlFor='input-max'>Max</label>

                                            <input
                                                type='number'
                                                id='input-step'
                                                defaultValue={step}
                                                onChange={( evt ) => {
                                                    this.editor.execute( 'insertSlider', 'retained-data-todo', {
                                                        min: min,
                                                        max: max,
                                                        step: evt.target.value,
                                                    } );
                                                }}
                                            />
                                            <label htmlFor='input-step'>Step</label>
                                        </>
                                    );
                                }
                            } ) }
                        </div>
                        <div id="toolbar-components">
                            <h4>Insert Component</h4>

                            <ul key="content-part-list-section" className="widget-list">
                                <ContentPartPreview
                                    key="insertSection"
                                    enabled={this.state.enabledCommands.includes('insertSection')}
                                    onClick={( id ) => {
                                        this.editor.execute( 'insertSection', id );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Section', id: uuidv4()}}
                                />
                            </ul>
                            <ul key="content-part-list-questions" className="widget-list">
                                <ContentPartPreview
                                    key="insertChecklistQuestion"
                                    enabled={this.state.enabledCommands.includes('insertChecklistQuestion')}
                                    onClick={( id ) => {
                                        this.editor.execute( 'insertChecklistQuestion', id );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Checklist Question', id: uuidv4()}}
                                />
                                <ContentPartPreview
                                    key="insertRadioQuestion"
                                    enabled={this.state.enabledCommands.includes('insertRadioQuestion')}
                                    onClick={( id ) => {
                                        this.editor.execute( 'insertRadioQuestion', id );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Radio Question', id: uuidv4()}}
                                />
                                <ContentPartPreview
                                    key="insertMatchingQuestion"
                                    enabled={this.state.enabledCommands.includes('insertMatchingQuestion')}
                                    onClick={( id ) => {
                                        this.editor.execute( 'insertMatchingQuestion', id );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Matching Question', id: uuidv4()}}
                                />
                                <ContentPartPreview
                                    key="insertTextAreaQuestion"
                                    enabled={this.state.enabledCommands.includes('insertTextAreaQuestion')}
                                    onClick={( id ) => {
                                        this.editor.execute( 'insertTextAreaQuestion', id );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Text Area Question', id: uuidv4()}}
                                />
                            </ul>
                            <ul key="content-part-list-content" className="widget-list">
                                <ContentPartPreview
                                    key="insertTableContent"
                                    enabled={this.state.enabledCommands.includes('insertTableContent')}
                                    onClick={( id ) => {
                                        const rows = window.prompt('How many rows?', 2);
                                        const columns = window.prompt('How many columns?', 2);
                                        this.editor.execute( 'insertTableContent', id , {rows: rows, columns: columns});
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Table', id: uuidv4()}}
                                />
                                <ContentPartPreview
                                    key="insertBlockquoteContent"
                                    enabled={this.state.enabledCommands.includes('insertBlockquoteContent')}
                                    onClick={( id ) => {
                                        this.editor.execute( 'insertBlockquoteContent', id );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Quote', id: uuidv4()}}
                                />
                                <ContentPartPreview
                                    key="insertIFrameContent"
                                    enabled={this.state.enabledCommands.includes('insertIFrameContent')}
                                    onClick={( id ) => {
                                        const url = window.prompt('URL', 'http://example.com' );
                                        this.editor.execute( 'insertIFrameContent', id, url );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'iFrame', id: uuidv4()}}
                                />
                                <ContentPartPreview
                                    key="insertVideoContent"
                                    enabled={this.state.enabledCommands.includes('insertVideoContent')}
                                    onClick={( id ) => {
                                        const url = window.prompt('URL', 'https://www.youtube.com/embed/yyRrKMb8oIg?rel=0' );
                                        this.editor.execute( 'insertVideoContent', id, url );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Video', id: uuidv4()}}
                                />
                            </ul>
                            <ul key="content-part-list-elements" className="widget-list">
                                <ContentPartPreview
                                    key="insertTextArea"
                                    enabled={this.state.enabledCommands.includes('insertTextArea')}
                                    onClick={( id ) => {
                                        this.editor.execute( 'insertTextArea', id );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Text Area', id: uuidv4()}}
                                />
                                <ContentPartPreview
                                    key="insertSlider"
                                    enabled={this.state.enabledCommands.includes('insertSlider')}
                                    onClick={( id ) => {
                                        this.editor.execute( 'insertSlider', id );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Slider', id: uuidv4()}}
                                />
                                <input
                                    type="file"
                                    style={{ display: "none" }}
                                    ref={this.fileUpload}
                                    onChange={e => {
                                        this.editor.execute( 'imageUpload', {file: e.target.files[0]} );
                                        this.editor.editing.view.focus();
                                    }}
                                />
                                <ContentPartPreview
                                    key="imageUpload"
                                    enabled={this.state.enabledCommands.includes('imageUpload')}
                                    onClick={this.showFileUpload}
                                    {...{name: 'Image (Upload)', id: uuidv4()}}
                                />
                                <ContentPartPreview
                                    key="imageInsert"
                                    enabled={this.state.enabledCommands.includes('imageInsert')}
                                    onClick={( id ) => {
                                        const url = window.prompt('URL', 'http://placekitten.com/200/300');
                                        this.editor.execute( 'imageInsert', {source: url} );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Image (URL)', id: uuidv4()}}
                                />
                            </ul>
                            <ul key="content-part-list-rtm" className="widget-list">
                                <ContentPartPreview
                                    key="insertRateThisModuleQuestion"
                                    enabled={this.state.enabledCommands.includes('insertRateThisModuleQuestion')}
                                    onClick={( id ) => {
                                        this.editor.execute( 'insertRateThisModuleQuestion', id );
                                        this.editor.editing.view.focus();
                                    }}
                                    {...{name: 'Rate This Module', id: uuidv4()}}
                                />
                            </ul>
                        </div>
                    </div>
                    <Tabs>
                        <div id="workspace">
                            <TabList id="view-mode">
                                <Tab className="active">Design</Tab>
                                <Tab>Code</Tab>
                            </TabList>
                            <TabPanel>
                                <div id="wysiwyg-container">
                                    <CKEditor
                                        editor={BalloonEditor}
                                        data={this.state.editorData}
                                        config={this.editorConfig}
                                        onChange={this.handleEditorDataChange}
                                        onInit={this.handleEditorInit}
                                    />
                                </div>
                                <textarea value={this.state.editorData}
                                          className="secret-html"
                                          readOnly={true}
                                          name="course_content[body]"></textarea>
                            </TabPanel>
                            <TabPanel>
                                <div id="raw-html-container">
                                    <textarea value={this.state.editorData}
                                              onChange={(evt) => this.handleHTMLEditorDataChange(evt)}
                                              name="course_content[body]"></textarea>
                                </div>
                            </TabPanel>
                        </div>
                    </Tabs>
                </main>
            </div>
        );
    }
}

export default ContentEditor;
