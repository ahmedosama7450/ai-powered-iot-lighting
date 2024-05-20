import { z } from "zod";

export function isPromptResultValid(promptResult: any) {
  // Make sure prompt result is in the correct format
  const lightingInfoSchema = z.array(
    z.object({
      duration: z
        .object({
          hours: z.number().nonnegative(),
          minutes: z.number().nonnegative(),
          seconds: z.number().nonnegative(),
        })
        .nullable(),
      shouldWaitForMotion: z.boolean().default(false),
      color: z.string().regex(/^#[0-9a-fA-F]{6}$/),
      isOn: z.boolean().default(true),
    })
  ).nonempty();

  const parseResult = lightingInfoSchema.safeParse(promptResult);
  return parseResult.success;
}

export function refinePromptResult(promptResult: any) {
  // Remove elements after the element with duration = null
  const indexOfNull = promptResult.findIndex(
    (item: any) => item.duration === null
  );

  if (indexOfNull < 0) {
    return promptResult;
  } else {
    return promptResult.slice(0, indexOfNull + 1);
  }
}
