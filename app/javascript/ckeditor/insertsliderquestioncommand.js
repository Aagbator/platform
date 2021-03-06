import Command from '@ckeditor/ckeditor5-core/src/command';
import { 
    DEFAULT_ANSWER, 
    DEFAULT_MIN, 
    DEFAULT_MAX, 
    DEFAULT_STEP,
} from '../constants/sliderquestionconstants';

export default class InsertSliderQuestionCommand extends Command {
    execute() {
        this.editor.model.change( writer => {
            this.editor.model.insertContent( createSliderQuestion( writer ) );
        } );
    }

    refresh() {
        const model = this.editor.model;
        const selection = model.document.selection;
        const allowedIn = model.schema.findAllowedParent( selection.getFirstPosition(), 'moduleBlock' );

        this.isEnabled = allowedIn !== null;
    }
}

function createSliderQuestion( writer ) {
    const sliderQuestion = writer.createElement( 'moduleBlock' );
    const question = writer.createElement( 'question', { 'data-grade-as': 'range' } );
    const questionTitle = writer.createElement( 'questionTitle' );
    const questionBody = writer.createElement( 'questionBody' );
    const questionBodyParagraph = writer.createElement( 'paragraph' );
    const questionForm = writer.createElement( 'questionForm' );
    const questionFieldset = writer.createElement( 'questionFieldset' );
    const slider = writer.createElement( 'slider', {
        'min': DEFAULT_MIN,
        'max': DEFAULT_MAX,
        'step': DEFAULT_STEP,
        'data-bz-range-answer': DEFAULT_ANSWER,
    } );
    const displayValueDiv = writer.createElement( 'displayValueDiv' );
    const currentValueSpan = writer.createElement( 'currentValueSpan' );

    writer.append( question, sliderQuestion );
    writer.append( questionTitle, question );
    writer.append( questionBody, question );
    writer.append( questionBodyParagraph, questionBody );
    writer.append( questionForm, question );
    writer.append( questionFieldset, questionForm );
    writer.append( slider, questionFieldset );
    writer.append( displayValueDiv, questionFieldset );
    writer.append( currentValueSpan, displayValueDiv );

    return sliderQuestion;
}
