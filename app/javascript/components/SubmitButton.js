import React from "react";

import { 
  Button,
  Spinner,
} from 'react-bootstrap'

class SubmitButton extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      isDisabled: props.isDisabled || false,
    }
  }

  _renderSpinner() {
    return (
      <div>
        <Spinner
          animation="border"
          as="span"
          className="align-middle"
          role="status"
          size="sm">
          <span className="sr-only">Saving</span>
        </Spinner>
        {' '}
        <span className="align-middle">{"Saving"}</span>
      </div>
    );
  }

  render() {
    return (
      <Button
        block
        disabled={this.state.isDisabled}
        onClick={() => this.setState({isDisabled: !this.state.isDisabled})}
        size="lg"
        type="submit">
        {this.state.isDisabled ? this._renderSpinner() : 'Save' }
      </Button>
    );
  }
}

export default SubmitButton;
