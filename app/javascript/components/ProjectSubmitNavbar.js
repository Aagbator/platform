import React from "react";

import {
  Form,
  Navbar,
} from 'react-bootstrap'

import SubmitButton from "./SubmitButton";


class ProjectSubmitNavbar extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      isSubmitting: false,
    }

    this._handleSubmit.bind(this);
  }

  _handleSubmit(event) {
  	event.preventDefault();

  	const form = event.target;
  	const data = new FormData(form);

  	this.setState({isSubmitting: true});

  	// FIXME: Don't hardcode this
  	fetch(
  	  '/course_contents/1/versions',
  	  {
  	  	method: 'POST',
  	  	data: data,
  	  },
  	 ).then(response => response)
  	.then(
  	  (result) => {
  	  	this.setState({isSubmitting: false})
  	  },
  	  (error) => {
  	  	// FIXME: handle errors
  	  }
  	)
  }

  render() {
  	// FIXME: Authenticity token issues
    return (
      <Navbar
        bg="transparent"
        className="justify-content-end"
      	fixed="bottom">
        <Form
          inline
          className="d-inline-block align-right"
          onSubmit={(event) => this._handleSubmit}>
          <input type="hidden" name="authenticity_token" value={this.props.authenticity_token} />
          <input type="hidden" name="state" value={this.props.lti_launch_state} />
      	  <SubmitButton isDisabled={this.state.isSubmitting} />
      	</Form>
      </Navbar>
    );
  }
}

export default ProjectSubmitNavbar;
