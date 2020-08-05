import React from "react";

import {
  Form,
  Navbar,
} from 'react-bootstrap'

import ProjectSubmitNavbar from "./ProjectSubmitNavbar";

class Project extends React.Component {
  constructor(props) {
    super(props);

    this._handleSubmit.bind(this);
  }

  _handleSubmit(event) {
    event.preventDefault();

    const form = event.target;
    const data = new FormData(form);

    // TODO: These go into the URL/data

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
        
      },
      (error) => {
        // FIXME: handle errors
      }
    )
  }

  _renderProject() {
    // FIXME: Investigate npm html-react-parser
    return (
      <div className="bz-assignment">
        <div dangerouslySetInnerHTML={{__html: this.props.body}} />
      </div>
    );
  }

  _renderSubmit() {
    if (!this.props.writeEnabled) {
      return null;
    }

    return (
      <ProjectSubmitNavbar
        authenticity_token={this.props.authenticity_token}
        lti_launch_state={this.props.lti_launch_state}
        onSubmit={this._handleSubmit}
      />
    );
  }

  render() {
    return (
      <div>
        {this._renderProject()}
        {this._renderSubmit()}
      </div>
    );
  }
}

export default Project;
