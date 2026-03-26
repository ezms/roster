import { builder } from './builder';

import './types/school';
import './types/user';
import './types/student';
import './types/attendance-session';
import './types/attendance-record';

export const schema = builder.toSchema();
