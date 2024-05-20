export interface LightingInfo {
  duration: { hours: number; minutes: number; seconds: number } | null; // default is: null

  shouldWaitForMotion: boolean; // default is: false

  color: string; // default is: #000000

  isOn: boolean; // default is: true
}
