import PropTypes from 'prop-types';
import { createRef } from 'react';

import { defineMessages, injectIntl } from 'react-intl';

import classNames from 'classnames';


class KTagComposeForm extends ImmutablePureComponent {
  render () {
    const { intl, onPaste, autoFocus, withoutNavigation, maxChars } = this.props;
    const { highlighted } = this.state;
    const disabled = this.props.isSubmitting;

    return (
      <form className='compose-form' onSubmit={this.handleSubmit}>
        <ReplyIndicator />
        {!withoutNavigation && <NavigationBar />}
        <WarningContainer />

        <div className={classNames('compose-form__highlightable', { active: highlighted })} ref={this.setRef}>
          <div className='compose-form__scrollable'>
            <EditIndicator />
          </div>

          <div className='compose-form__footer'>

            <div className='compose-form__actions'>
            <Textarea
              className='autosuggest-textarea__textarea'
              />
              <div className='compose-form__submit'>
                <Button
                  type='submit'
                  text={intl.formatMessage(this.props.isEditing ? messages.saveChanges : (this.props.isInReply ? messages.reply : messages.publish))}
                  disabled={!this.canSubmit()}
                />
              </div>
            </div>
          </div>
        </div>
      </form>
    );
  }
}
export default withOptionalRouter(injectIntl(KTagComposeForm));