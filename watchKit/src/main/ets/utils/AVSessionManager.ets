import avSession from '@ohos.multimedia.avsession';
import { BusinessError } from '@ohos.base';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import wantAgent from '@ohos.app.ability.wantAgent';
import bundleManager from '@ohos.bundle.bundleManager';
import common from '@ohos.app.ability.common';
import ApplicationStateChangeCallback from '@ohos.app.ability.ApplicationStateChangeCallback';
import audio from '@ohos.multimedia.audio';
import appManager from '@ohos.app.ability.appManager';

export enum AudioSessionConcurrencyMode {
  AudioSessionConcurrencyModeNone = 0,
  AudioSessionConcurrencyModeDefault = 1,
  AudioSessionConcurrencyModeMixWithOthers = 2,
  AudioSessionConcurrencyModeDuckOthers = 3,
  AudioSessionConcurrencyModePauseOthers = 4,
}

export class AVSessionManager {
  public static audioSessionConcurrencyMode : AudioSessionConcurrencyMode = AudioSessionConcurrencyMode.AudioSessionConcurrencyModeNone;

  public async start() {
    await this.startAVSession();
    await this.startBackgroundTask();
    await this.startAudioSession();
    try {
      getContext().getApplicationContext().on('applicationStateChange', this.applicationStateChangeCallback);

      let processInfo = await getContext().getApplicationContext().getRunningProcessInformation();
      this.isOnBackground == (processInfo[0].state == appManager.ProcessState.STATE_BACKGROUND);
    } catch (err) {
      console.error("AVSessionManager failed to listen applicationStateChane" + JSON.stringify(err));
    }

    this.isStarted = true;
  }

  public async stop() {
    this.isStarted = false;
    try {
      getContext().getApplicationContext().off('applicationStateChange', this.applicationStateChangeCallback);
    } catch (err) {}

    await this.stopAVSession();
    await this.stopBackgroundTask();
    await this.stopAudioSession();
  }

  private isStarted: boolean = false;
  private avSession: avSession.AVSession | null = null;
  private audioSessionManager: audio.AudioSessionManager = audio.getAudioManager().getSessionManager();
  private isOnBackground: boolean = false;

  private applicationStateChangeCallback : ApplicationStateChangeCallback = {
    onApplicationForeground: () => {
      this.isOnBackground = false;
      if (this.isStarted) {
        this.startAudioSession();
      }
    },
    onApplicationBackground: () => {
      this.isOnBackground = true;
      if (this.isStarted) {
        this.startBackgroundTask();
      }
    }
  };

  private audioSessionDeactivated = (event: audio.AudioSessionDeactivatedEvent) => {
    console.error('AVSessionManager audioSessionDeactivated reason = ' + event.reason);
    if (event.reason == audio.AudioSessionDeactivatedReason.DEACTIVATED_TIMEOUT || !this.isOnBackground) {
      if (this.isStarted) {
        this.startAudioSession();
      }
    }
  }

  private async startAudioSession(): Promise<void> {
    if (AVSessionManager.audioSessionConcurrencyMode == AudioSessionConcurrencyMode.AudioSessionConcurrencyModeNone) {
      return;
    }
    try {
      let mode = audio.AudioConcurrencyMode.CONCURRENCY_DEFAULT;
      if (AVSessionManager.audioSessionConcurrencyMode == AudioSessionConcurrencyMode.AudioSessionConcurrencyModeMixWithOthers) {
        mode = audio.AudioConcurrencyMode.CONCURRENCY_MIX_WITH_OTHERS;
      } else if (AVSessionManager.audioSessionConcurrencyMode == AudioSessionConcurrencyMode.AudioSessionConcurrencyModeDuckOthers) {
        mode = audio.AudioConcurrencyMode.CONCURRENCY_DUCK_OTHERS;
      } else if (AVSessionManager.audioSessionConcurrencyMode == AudioSessionConcurrencyMode.AudioSessionConcurrencyModePauseOthers) {
        mode = audio.AudioConcurrencyMode.CONCURRENCY_PAUSE_OTHERS;
      }
      await this.audioSessionManager?.activateAudioSession( {concurrencyMode: mode } );
      this.audioSessionManager.on('audioSessionDeactivated', this.audioSessionDeactivated);
      console.error('AVSessionManager activate AudioSession');
    } catch (err) {
      console.error('AVSessionManager Failed to activate AudioSession' + JSON.stringify(err));
    }
  }

  private async stopAudioSession(): Promise<void> {
    try {
      await this.audioSessionManager?.deactivateAudioSession();
      this.audioSessionManager.off('audioSessionDeactivated', this.audioSessionDeactivated);

      console.error('AVSessionManager deactivate AudioSession');
    } catch (err) {
      console.error('AVSessionManager Failed to deactivate AudioSession' + JSON.stringify(err));
    }
  }

  private async startAVSession(): Promise<void> {
    try {
      this.avSession = await avSession.createAVSession(getContext(), "hmopensdk", "video");
      await this.avSession.activate();

      console.error('AVSessionManager create and activate AVSession');
    } catch (err) {
      console.error('AVSessionManager Failed to create or activate AVSession' + JSON.stringify(err));
    }
  }

  private async stopAVSession(): Promise<void> {
    try {
      await this.avSession?.deactivate();
      await this.avSession?.destroy();
      this.avSession = null;

      console.error('AVSessionManager deactivate and destroy AVSession');
    } catch (err) {
      console.error('AVSessionManager Failed to deactivate or destroy AVSession' + JSON.stringify(err));
    }
  }

  private async startBackgroundTask(): Promise<void> {
    try {
      let wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: this.getBundleName(),
            abilityName: this.getUIAbilityName(),
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };
      let want = await wantAgent.getWantAgent(wantAgentInfo);
      await backgroundTaskManager.startBackgroundRunning(getContext(), ['audioRecording', 'audioPlayback'], want);

      console.error('AVSessionManager start background task');
    } catch (err) {
      console.error('AVSessionManager Failed to start background task' + JSON.stringify(err));
    }
  }

  private async stopBackgroundTask(): Promise<void> {
    try {
      await backgroundTaskManager.stopBackgroundRunning(getContext());
      console.error('AVSessionManager stop background task');
    } catch (err) {
      console.error('AVSessionManager Failed to stop background task' + JSON.stringify(err));
    }
  }

  private getBundleName(): string {
    let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
    return bundleInfo.name;
  }

  private getUIAbilityName(): string {
    let context = getContext() as common.UIAbilityContext;
    return context.abilityInfo.name;
  }
}